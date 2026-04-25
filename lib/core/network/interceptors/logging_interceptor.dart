import 'dart:convert';
import 'package:dio/dio.dart';
import '../../services/log_service.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logService);

  final LogService _logService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final logBuffer = StringBuffer();
    logBuffer.writeln('REQUEST[${options.method}] => PATH: ${options.path}');
    logBuffer.writeln('URL: ${options.uri}');
    logBuffer.writeln('Headers: ${jsonEncode(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      logBuffer.writeln(
        'Query Parameters: ${jsonEncode(options.queryParameters)}',
      );
    }
    if (options.data != null) {
      logBuffer.writeln('Body: ${_prettyJson(options.data)}');
    }

    await _logService.log(logBuffer.toString());
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final logBuffer = StringBuffer();
    logBuffer.writeln(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    if (response.data != null) {
      logBuffer.writeln('Body: ${_prettyJson(response.data)}');
    }

    await _logService.log(logBuffer.toString());
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final logBuffer = StringBuffer();
    logBuffer.writeln(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    logBuffer.writeln('Type: ${err.type}');
    logBuffer.writeln('Message: ${err.message}');
    if (err.response?.data != null) {
      logBuffer.writeln('Error Body: ${_prettyJson(err.response?.data)}');
    } else if (err.error != null) {
      logBuffer.writeln('Error Details: ${err.error}');
    }

    await _logService.log(logBuffer.toString());
    handler.next(err);
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        return data;
      }
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
