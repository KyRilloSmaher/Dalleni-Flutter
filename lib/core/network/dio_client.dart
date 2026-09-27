import 'package:dalleni/core/constants/app_constants.dart';
import 'package:dalleni/core/network/interceptors/auth_interceptor.dart';
import 'package:dalleni/core/network/interceptors/logging_interceptor.dart';
import 'package:dalleni/core/providers/core_providers.dart';
import 'package:dalleni/core/services/log_service.dart';
import 'package:dalleni/core/services/token_scheduler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart' hide AuthRemoteDataSource, AuthRemoteDataSourceImpl;
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/services/fcm_service.dart';


final tokenSchedulerProvider = Provider<TokenScheduler>((ref) {
  return TokenScheduler();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {//Dio for Auth
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(LoggingInterceptor(ref.read(logServiceProvider)));

  return AuthRemoteDataSourceImpl(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localStorageService: ref.read(localStorageServiceProvider),
    tokenScheduler: ref.read(tokenSchedulerProvider),
  );
});

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(ref.read(logServiceProvider)),
    AuthInterceptor(
      localStorageService: ref.read(localStorageServiceProvider),
      authRepository: ref.read(authRepositoryProvider),
      logService: ref.read(logServiceProvider),
    ),
  ]);

  return dio;
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSourceImpl(ref.read(dioClientProvider));
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    remoteDataSource: ref.read(notificationsRemoteDataSourceProvider),
    localStorageService: ref.read(localStorageServiceProvider),
  );
});
