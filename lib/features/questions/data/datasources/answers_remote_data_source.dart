import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_exception.dart';
import '../models/question_model.dart';

abstract class AnswersRemoteDataSource {
  Future<List<AnswerModel>> getAnswers(String questionId);
  Future<bool> createAnswer(AnswerModel answer);
  Future<bool> voteAnswer(String id, int type);
  Future<bool> acceptAnswer(String answerId, String questionId);
}

class AnswersRemoteDataSourceImpl implements AnswersRemoteDataSource {
  AnswersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AnswerModel>> getAnswers(String questionId) async {
    try {
      final response = await _dio.get('/answers/question/$questionId');
      final apiResponse = ApiResponse<List<AnswerModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            (json as List<dynamic>?)
                ?.map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> createAnswer(AnswerModel answer) async {
    try {
      final response = await _dio.post('/answers', data: answer.toCreateJson());
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> voteAnswer(String id, int type) async {
    try {
      final response = await _dio.post(
        '/votes/answer/$id',
        queryParameters: {'type': type},
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> acceptAnswer(String answerId, String questionId) async {
    try {
      final response = await _dio.post(
        '/questions/accept-answer/$answerId',
        queryParameters: {'questionId': questionId},
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      return apiResponse.succeeded;
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
    return ApiException(
      message: error.message ?? 'Request failed.',
      statusCode: error.response?.statusCode,
    );
  }
}
