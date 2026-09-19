import 'package:dio/dio.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../services/log_service.dart';
import '../../storage/local_storage_service.dart';
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
  Future<dynamic>? _refreshFuture;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _localStorageService.getToken();
    print(
      '[AUTH DEBUG] get access token: ${accessToken != null && accessToken.isNotEmpty} (instance: ${identityHashCode(_localStorageService)}, path: ${options.path})',
    );
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
    final path = err.requestOptions.path;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        !path.contains('/auth/login') &&
        !path.contains('/auth/refresh-token');

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final requestHeaderToken =
        err.requestOptions.headers['Authorization'] as String?;
    final storedToken = _localStorageService.getToken();

    // Check if token was already refreshed by another concurrent request
    final hasBeenRefreshedByOther =
        storedToken != null &&
        storedToken.isNotEmpty &&
        requestHeaderToken != 'Bearer $storedToken';

    if (hasBeenRefreshedByOther) {
      await _logService.log(
        '[AUTH DEBUG] Token was already refreshed by another request. Retrying request directly (${err.requestOptions.path}).',
      );
      try {
        final retriedResponse = await _retry(err.requestOptions, storedToken);
        handler.resolve(retriedResponse);
        return;
      } catch (_) {
        handler.next(err);
        return;
      }
    }

    final refreshToken = _localStorageService.getRefreshToken();
    if (storedToken == null ||
        refreshToken == null ||
        storedToken.isEmpty ||
        refreshToken.isEmpty) {
      final msg =
          '[AUTH DEBUG] 401 encountered on ${err.requestOptions.path} with missing tokens.'
          '\nAccess Token Present: ${storedToken != null && storedToken.isNotEmpty}'
          '\nRefresh Token Present: ${refreshToken != null && refreshToken.isNotEmpty}'
          '\nLocalStorage Instance: ${identityHashCode(_localStorageService)}';
      await _logService.log(msg);
      print(msg);
      print('[AUTH DEBUG] Calling _authRepository.logout() due to missing tokens on 401');
      await _authRepository.logout();
      handler.next(err);
      return;
    }

    try {
      print('[AUTH DEBUG] Attempting refresh-token operation triggered by path: ${err.requestOptions.path}');
      if (_isRefreshing) {
        if (_refreshFuture != null) {
          await _refreshFuture;
        }
      } else {
        _isRefreshing = true;
        _refreshFuture = _authRepository.refreshToken(
          accessToken: storedToken,
          refreshToken: refreshToken,
        );
        try {
          await _refreshFuture;
        } finally {
          _isRefreshing = false;
          _refreshFuture = null;
        }
      }

      final latestToken = _localStorageService.getToken();
      if (latestToken == null || latestToken.isEmpty) {
        print('[AUTH DEBUG] Refresh succeeded but latestToken is null/empty. Calling logout()');
        await _authRepository.logout();
        handler.next(err);
        return;
      }

      final retriedResponse = await _retry(err.requestOptions, latestToken);
      handler.resolve(retriedResponse);
    } catch (error) {
      final msg =
          '[AUTH DEBUG] Refresh token operation or retry failed for path ${err.requestOptions.path}: $error';
      await _logService.log(msg);
      print(msg);
      print('[AUTH DEBUG] Calling _authRepository.logout() due to refresh failure');
      await _authRepository.logout();
      handler.next(err);
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    String accessToken,
  ) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $accessToken';

    final retryDio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        connectTimeout: requestOptions.connectTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
      ),
    )..interceptors.add(LoggingInterceptor(_logService));

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      extra: requestOptions.extra,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      listFormat: requestOptions.listFormat,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
    );

    return retryDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onSendProgress: requestOptions.onSendProgress,
      onReceiveProgress: requestOptions.onReceiveProgress,
    );
  }
}
