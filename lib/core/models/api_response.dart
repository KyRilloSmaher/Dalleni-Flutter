class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.succeeded,
    required this.message,
    required this.errorsBag,
    required this.data,
  });

  final int statusCode;
  final bool succeeded;
  final String message;
  final Map<String, List<String>> errorsBag;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T? Function(Object? json)? fromJsonT,
  }) {
    final errorsBagJson = (json['errorsBag'] as Map<String, dynamic>? ?? {});

    return ApiResponse<T>(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      succeeded: json['succeeded'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      errorsBag: errorsBagJson.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>? ?? <dynamic>[])
              .map((item) => item.toString())
              .toList(growable: false),
        ),
      ),
      data: fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
    );
  }
}
