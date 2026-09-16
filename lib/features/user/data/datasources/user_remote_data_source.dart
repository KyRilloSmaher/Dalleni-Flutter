import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/user_profile.dart';
import '../models/update_user_model.dart';
import '../models/user_response_model.dart';

abstract class UserRemoteDataSource {
  Future<UserProfile> getProfile();
  Future<String> updateProfileImage(String userId, File profileImage);
  Future<UserProfile> updateProfile(UpdateUserAccount request);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      final apiResponse = ApiResponse<UserResponseDto>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            UserResponseDto.fromJson(json as Map<String, dynamic>),
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
      throw mapDioException(error);
    }
  }

  @override
  Future<String> updateProfileImage(String userId, File profileImage) async {
    try {
      final formData = FormData.fromMap({
        'Id': userId,
        'ProfileImage': await MultipartFile.fromFile(profileImage.path),
      });

      final response = await _dio.post(
        '/users/update-profile-image',
        data: formData,
      );

      final apiResponse = ApiResponse<String>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as String? ?? '',
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
      throw mapDioException(error);
    }
  }

  @override
  Future<UserProfile> updateProfile(UpdateUserAccount request) async {
    try {
      final response = await _dio.put(
        '/users/update-profile',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<UserResponseDto>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            UserResponseDto.fromJson(json as Map<String, dynamic>),
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
      throw mapDioException(error);
    }
  }
}

