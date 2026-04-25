import 'package:dio/dio.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../storage/local_storage_service.dart';
import '../../services/log_service.dart';
import 'logging_interceptor.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required LocalStorageService localStorageService,
    required AuthRepository authRepository,
    required LogService logService,
  }) : _localStorageService = localStorageService,
       _authRepository = authRepository,
       _logService = logService;

  final LocalStorageService _localStorageService;
  final AuthRepository _authRepository;
  final LogService _logService;

  bool _isRefreshing = false;
  Future<void>? _refreshFuture;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _localStorageService.getToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        !err.requestOptions.path.endsWith('/auth/login') &&
        !err.requestOptions.path.endsWith('/auth/refresh-token');

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final accessToken = _localStorageService.getToken();
    final refreshToken = _localStorageService.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      await _authRepository.logout();
      handler.next(err);
      return;
    }

    try {
      if (_isRefreshing) {
        await _refreshFuture;
      } else {
        _isRefreshing = true;
        _refreshFuture = _authRepository
            .refreshToken(accessToken: accessToken, refreshToken: refreshToken)
            .then((_) {});
        await _refreshFuture;
      }

      final retriedRequest = await _retry(err.requestOptions);
      handler.resolve(retriedRequest);
    } catch (_) {
      await _authRepository.logout();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        connectTimeout: requestOptions.connectTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        headers: Map<String, dynamic>.from(requestOptions.headers),
      ),
    )..interceptors.add(LoggingInterceptor(_logService));
    final latestAccessToken = _localStorageService.getToken();
    final headers = Map<String, dynamic>.from(requestOptions.headers);

    if (latestAccessToken != null && latestAccessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $latestAccessToken';
    }

    return dio.fetch<dynamic>(requestOptions.copyWith(headers: headers));
  }
}
