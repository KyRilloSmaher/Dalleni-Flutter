import 'package:dalleni/core/services/token_scheduler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../constants/app_constants.dart';
import '../providers/core_providers.dart';
import '../services/log_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

final tokenSchedulerProvider = Provider<TokenScheduler>((ref) {
  return TokenScheduler();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
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
