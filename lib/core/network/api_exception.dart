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
