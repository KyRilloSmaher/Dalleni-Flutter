import 'package:dio/dio.dart';
import '../models/api_response.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, List<String>>? errors;

  /// Get validation error for a specific field.
  String? getFieldError(String field) {
    if (errors == null) return null;

    // Exact match
    final fieldErrors = errors![field];

    if (fieldErrors != null && fieldErrors.isNotEmpty) {
      return fieldErrors.first;
    }

    // Case-insensitive match
    final key = errors!.keys.cast<String?>().firstWhere(
      (key) => key?.toLowerCase() == field.toLowerCase(),
      orElse: () => null,
    );

    if (key != null && errors![key] != null && errors![key]!.isNotEmpty) {
      return errors![key]!.first;
    }

    return null;
  }

  /// Get the first validation error from the errors bag.
  String? get firstFieldError {
    if (errors == null || errors!.isEmpty) {
      return null;
    }

    for (final fieldErrors in errors!.values) {
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.first;
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'ApiException('
        'statusCode: $statusCode, '
        'message: $message, '
        'errors: $errors'
        ')';
  }
}

ApiException mapDioException(DioException e) {
  if (e.response?.statusCode == 400) {
    final data = e.response?.data;

    if (data is Map) {
      final errorsBagJson = data['errorsBag'];
      Map<String, List<String>>? errors;
      if (errorsBagJson is Map) {
        errors = errorsBagJson.map(
          (k, v) => MapEntry(
            k.toString(),
            (v as List<dynamic>? ?? <dynamic>[])
                .map((item) => item.toString())
                .toList(),
          ),
        );
      }

      return ApiException(
        message: data['message']?.toString() ?? 'Bad request',
        statusCode: 400,
        errors: errors,
      );
    }
  }

  return ApiException(
    message: e.message ?? 'Something went wrong',
    statusCode: e.response?.statusCode,
  );
}
