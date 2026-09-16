import 'package:dio/dio.dart';

import '../models/api_response.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}

ApiException mapDioException(DioException error) {
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



