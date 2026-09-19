import 'package:dalleni/core/error/failure.dart';
import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/network/api_exception.dart';
import '../models/question_model.dart';

abstract class AnswersRemoteDataSource {
  Future<List<AnswerModel>> getAnswers(String questionId);
  Future<bool> createAnswer(AnswerModel answer);
  Future<bool> deleteAnswer(String answer);
  Future<bool> voteAnswer(String id, int type);
  Future<bool> acceptAnswer(String answerId, String questionId);
}

class AnswersRemoteDataSourceImpl implements AnswersRemoteDataSource {
  AnswersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AnswerModel>> getAnswers(String questionId) async {
    try {
      final response = await _dio.get('/answers/question/$questionId/answers');
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
      throw mapDioException(error);
    }
  }

  @override
  Future<bool> createAnswer(AnswerModel answer) async {
    try {
      final response = await _dio.post(
        '/answers/create',
        data: answer.toCreateJson(),
      );
      final apiResponse = ApiResponse<String>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as String?,
      );

      return apiResponse.succeeded;
    } on DioException catch (e) {
      throw ServerFailure(
        mapDioException(e).errors?.values.first.toString() ?? "",
      );
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  Future<bool> deleteAnswer(String answerId)async{
    try {
      final response = await _dio.delete(
        '/answers/${answerId}/delete'
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool?,
      );

      return apiResponse.succeeded;
    } on DioException catch (e) {
      throw ServerFailure(
        mapDioException(e).errors?.values.first.toString() ?? "",
      );
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }

  }

  @override
  Future<bool> voteAnswer(String id, int type) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/votes/answer/$id',
        data: <String, dynamic>{'type': type},
        queryParameters: <String, dynamic>{'type': type},
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      throw mapDioException(error);
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
      throw mapDioException(error);
    }
  }
}
