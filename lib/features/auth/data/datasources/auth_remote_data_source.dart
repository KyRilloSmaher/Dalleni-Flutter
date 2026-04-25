import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_exception.dart';
import '../models/auth_session_model.dart';
import '../models/confirm_reset_code_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/sign_up_request_model.dart';
import '../models/verfiy_identitiy_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login(LoginRequestModel request);
  Future<AuthSessionModel> refreshToken(RefreshTokenRequestModel request);
  Future<bool> signUp(SignUpRequestModel request);
  Future<bool> verifyOtp(VerfiyOTPRequestModel request);
  Future<dynamic> getGoogleLogin();

  /// Forgot-password flow
  Future<bool> sendResetCode(ForgotPasswordRequestModel request);
  Future<bool> confirmResetCode(ConfirmResetCodeRequestModel request);
  Future<bool> resetPassword(ResetPasswordRequestModel request);
  Future<bool> resendResetCode(ForgotPasswordRequestModel request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthSessionModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<AuthSessionModel>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            AuthSessionModel.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<AuthSessionModel> refreshToken(
    RefreshTokenRequestModel request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<AuthSessionModel>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            AuthSessionModel.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> verifyOtp(VerfiyOTPRequestModel request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? false,
      );
      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> signUp(SignUpRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/sign-up',
        data: await request.toFormData(),
        options: Options(contentType: 'multipart/form-data'),
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? false,
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<dynamic> getGoogleLogin() async {
    try {
      final response = await _dio.get<dynamic>('/auth/google-login');
      return response.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  // ─── Forgot-password flow ──────────────────────────────────────────────────

  @override
  Future<bool> sendResetCode(ForgotPasswordRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/send-reset-code',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? false,
      );
      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }
      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> confirmResetCode(ConfirmResetCodeRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/confirm-reset-password-code',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? false,
      );
      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }
      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? false,
      );
      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }
      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> resendResetCode(ForgotPasswordRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/resend-reset-code',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? false,
      );
      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }
      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  ApiException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final apiResponse = ApiResponse<dynamic>.fromJson(responseData);
      return ApiException(
        message: apiResponse.message.isEmpty
            ? error.message ?? 'Request failed.'
            : apiResponse.message,
        statusCode: apiResponse.statusCode,
        errors: apiResponse.errorsBag,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(message: 'TIMEOUT');
    }

    return ApiException(
      message: error.message ?? 'Request failed.',
      statusCode: error.response?.statusCode,
    );
  }
}
