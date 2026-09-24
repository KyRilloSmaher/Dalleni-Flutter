import 'package:dalleni/core/error/failure.dart';
import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/models/paged_list.dart';
import '../../../../core/network/api_exception.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/saved_question_model.dart';
import '../models/tag_model.dart';

abstract class QuestionsRemoteDataSource {
  Future<PagedList<QuestionModel>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<PagedList<QuestionModel>> searchQuestions({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<PagedList<QuestionModel>> getQuestionsByTag({
    required String tagId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<PagedList<QuestionModel>> getQuestionsByCategory({
    required String categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<QuestionModel> getQuestion(String id);
  Future<bool> createQuestion(QuestionModel question);
  Future<bool?> voteQuestion(String id, int type);
  Future<bool> removevote(String voteId);
  Future<Map<String, String>> getUserQuestionVotes();
  Future<List<CategoryModel>> getCategories();
  Future<List<TagModel>> getTags({int pageNumber = 1, int pageSize = 20});
  Future<String?> saveQuestion(String questionId, String userId);
  Future<bool> unsaveQuestion(String savedQuestionId);
  Future<List<SavedQuestionModel>> getSavedQuestions();
}

class QuestionsRemoteDataSourceImpl implements QuestionsRemoteDataSource {
  QuestionsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedList<QuestionModel>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/questions',
        queryParameters: <String, dynamic>{
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return _parsePagedQuestionsResponse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<PagedList<QuestionModel>> searchQuestions({
    required String query,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/questions/search',
        queryParameters: <String, dynamic>{
          'query': query,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return _parsePagedQuestionsResponse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<PagedList<QuestionModel>> getQuestionsByTag({
    required String tagId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tags/${tagId}/questions',
        queryParameters: <String, dynamic>{
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return _parsePagedQuestionsResponse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<PagedList<QuestionModel>> getQuestionsByCategory({
    required String categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/categories/$categoryId/questions',
        queryParameters: <String, dynamic>{
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      final apiResponse = ApiResponse<PagedList<QuestionModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => PagedList<QuestionModel>.fromJson(
          json as Map<String, dynamic>,
          (json) => QuestionModel.fromJson(json as Map<String, dynamic>),
        ),
      );

      if (!apiResponse.succeeded) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return apiResponse.data ??
          const PagedList<QuestionModel>(
            items: [],
            pageNumber: 1,
            totalPages: 0,
            totalCount: 0,
            hasPreviousPage: false,
            hasNextPage: false,
          );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<QuestionModel> getQuestion(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/questions/$id');
      final apiResponse = ApiResponse<QuestionModel>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            QuestionModel.fromJson(json as Map<String, dynamic>),
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
  Future<bool> createQuestion(QuestionModel question) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/questions',
        data: question.toCreateJson(),
      );
      final apiResponse = ApiResponse<String>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as String? ?? "",
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
  Future<bool> voteQuestion(String id, int type) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/votes/question/$id',
        queryParameters: <String, dynamic>{'type': type},
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json is bool ? json : true,
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<bool> removevote(String voteId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/votes/$voteId/remove',
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json is bool ? json : true,
      );

      return apiResponse.succeeded;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<Map<String, String>> getUserQuestionVotes() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/votes/user/votes/questions',
      );
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as List<dynamic>? ?? <dynamic>[],
      );

      final result = <String, String>{};
      if (apiResponse.succeeded && apiResponse.data != null) {
        for (final item in apiResponse.data!) {
          if (item is Map<String, dynamic>) {
            final voteId =
                item['voteId']?.toString() ?? item['id']?.toString();
            final questionObj = item['question'];
            final questionId = (questionObj is Map)
                ? questionObj['id']?.toString()
                : item['questionId']?.toString();

            if (voteId != null &&
                voteId.isNotEmpty &&
                questionId != null &&
                questionId.isNotEmpty) {
              result[questionId] = voteId;
            }
          }
        }
      }
      return result;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/categories');
      final apiResponse = ApiResponse<List<CategoryModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => (json as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList(growable: false),
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
  Future<List<TagModel>> getTags({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tags',
        queryParameters: <String, dynamic>{
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      final apiResponse = ApiResponse<PagedList<TagModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => PagedList<TagModel>.fromJson(
          json as Map<String, dynamic>,
          (item) => TagModel.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return apiResponse.data!.items;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<String?> saveQuestion(String questionId, String userId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/saved-questions/add',
        data: <String, dynamic>{'questionId': questionId, 'userId': userId},
      );
      final apiResponse = ApiResponse<String?>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: _parseSavedQuestionRecordId,
      );

      if (!apiResponse.succeeded) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return apiResponse.data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<bool> unsaveQuestion(String savedQuestionId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/saved-questions/$savedQuestionId/remove',
      );
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => json as bool? ?? true,
      );

      if (!apiResponse.succeeded) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return true;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<SavedQuestionModel>> getSavedQuestions() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user/saved-questions',
      );
      final apiResponse = ApiResponse<List<SavedQuestionModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => (json as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(SavedQuestionModel.fromJson)
            .toList(growable: false),
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

  PagedList<QuestionModel> _parsePagedQuestionsResponse(
    Map<String, dynamic>? responseData,
  ) {
    final apiResponse = ApiResponse<PagedList<QuestionModel>>.fromJson(
      responseData ?? <String, dynamic>{},
      fromJsonT: (json) => PagedList<QuestionModel>.fromJson(
        json as Map<String, dynamic>,
        (item) => QuestionModel.fromJson(item as Map<String, dynamic>),
      ),
    );

    if (!apiResponse.succeeded || apiResponse.data == null) {
      throw ApiException(
        message: apiResponse.message,
        statusCode: apiResponse.statusCode,
      );
    }

    return apiResponse.data!;
  }

  String? _parseSavedQuestionRecordId(Object? json) {
    if (json is Map) {
      final id = json['id']?.toString();
      if (id != null && id.isNotEmpty) {
        return id;
      }
    }
    return null;
  }

}
