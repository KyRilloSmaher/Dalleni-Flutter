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
  Future<bool> removevote(String idanswer);
  Future<bool> acceptAnswer(String answerId);
  Future<bool> unacceptAnswer(String answerId);
  Future<String?> markAnswer(String answerId);
  Future<String?> markUnsuccessfulAnswer(String answerId);
  Future<bool> removemarkAnswer(String successRecordId);
  Future<Map<String, String>> getUserAnswerVotes();
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

  Future<bool> deleteAnswer(String answerId) async {
    try {
      final response = await _dio.delete('/answers/${answerId}/delete');
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
        queryParameters: <String, dynamic>{'type': type},
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data ?? <String, dynamic>{},
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];

        if (message is String && message.isNotEmpty) {
          throw ServerFailure(message);
        }
      }

      throw ServerFailure(
        mapDioException(error).message ?? 'Something went wrong',
      );
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<bool> removevote(String voteid) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/votes/$voteid/remove',
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json is bool ? json : true,
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      throw ServerFailure(
        mapDioException(error).errors?.values.first.toString() ?? "",
      );
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<bool> acceptAnswer(String answerId) async {
    try {
      final response = await _dio.post('/answers/$answerId/accept-answer');
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      return apiResponse.succeeded;
    } on DioException catch (e) {
      throw ServerFailure(mapDioException(e).message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<bool> unacceptAnswer(String answerId) async {
    try {
      final response = await _dio.post('/answers/$answerId/unaccept-answer');
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      return apiResponse.succeeded;
    } on DioException catch (e) {
      throw ServerFailure(mapDioException(e).message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String?> markAnswer(String answerId) async {
    try {
      final response = await _dio.post('/answers/$answerId/mark-as-successful');
      return _extractSuccessRecordId(response.data);
    } on DioException catch (e) {
      throw ServerFailure(mapDioException(e).message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String?> markUnsuccessfulAnswer(String answerId) async {
    try {
      final response = await _dio.post(
        '/answers/$answerId/mark-as-unsuccessful',
      );
      return _extractSuccessRecordId(response.data);
    } on DioException catch (e) {
      throw ServerFailure(mapDioException(e).message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<bool> removemarkAnswer(String successRecordId) async {
    try {
      final response = await _dio.delete(
        '/answers/successful-mark/$successRecordId/delete',
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      return apiResponse.succeeded;
    } on DioException catch (e) {
      throw ServerFailure(mapDioException(e).message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  String? _extractSuccessRecordId(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final innerData = responseData['data'];
      if (innerData is Map<String, dynamic>) {
        final id = innerData['successRecordId']?.toString() ??
            innerData['recordId']?.toString() ??
            innerData['id']?.toString();
        if (id != null && id.isNotEmpty) return id;
      } else if (innerData is String && innerData.isNotEmpty) {
        return innerData;
      }

      final directId = responseData['successRecordId']?.toString() ??
          responseData['recordId']?.toString() ??
          responseData['id']?.toString();
      if (directId != null && directId.isNotEmpty) return directId;
    }
    return null;
  }

  @override
  Future<Map<String, String>> getUserAnswerVotes() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/votes/user/votes/answers',
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as List<dynamic>? ?? <dynamic>[],
      );

      final result = <String, String>{};

      if (apiResponse.succeeded && apiResponse.data != null) {
        for (final item in apiResponse.data!) {
          if (item is! Map<String, dynamic>) {
            continue;
          }

          final voteId = item['voteId']?.toString();

          final answerObj = item['answer'];

          final answerId = answerObj is Map
              ? answerObj['id']?.toString()
              : item['answerId']?.toString();

          if (voteId != null &&
              voteId.isNotEmpty &&
              answerId != null &&
              answerId.isNotEmpty) {
            result[answerId] = voteId;
          }
        }
      }

      return result;
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];

        if (message is String && message.isNotEmpty) {
          throw ServerFailure(message);
        }
      }

      throw ServerFailure(mapDioException(error).message);
    }
  }
}
