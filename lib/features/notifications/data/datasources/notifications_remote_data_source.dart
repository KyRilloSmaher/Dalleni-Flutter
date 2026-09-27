import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_exception.dart';
import '../models/device_registration_request_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<String> registerDevice(DeviceRegistrationRequestModel request);
  Future<void> deactivateDevice(String deviceId);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<String> registerDevice(DeviceRegistrationRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user-devices/register-device',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data ?? <String, dynamic>{},
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }

      final data = apiResponse.data;
      print('Device Id  ${data}');
      if (data is String) {
        return data;
      } else if (data is Map<String, dynamic>) {
        return data['deviceId']?.toString() ??
            data['id']?.toString() ??
            data['data']?.toString() ??
            '';
      }
      return data.toString();
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<void> deactivateDevice(String deviceId) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/user-devices/deactivate-device',
        queryParameters: {'deviceId': deviceId},
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data ?? <String, dynamic>{},
      );

      if (!apiResponse.succeeded) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
          errors: apiResponse.errorsBag,
        );
      }
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
    );
  }
}
