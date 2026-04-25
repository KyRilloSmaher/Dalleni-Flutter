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
  Future<bool> voteQuestion(String id, int type);
  Future<List<CategoryModel>> getCategories();
  Future<List<TagModel>> getTags({int pageNumber = 1, int pageSize = 20});
  Future<bool> saveQuestion(String questionId, String userId);
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
      throw _mapDioException(error);
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
      throw _mapDioException(error);
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
        '/questions/tag/$tagId',
        queryParameters: <String, dynamic>{
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      return _parsePagedQuestionsResponse(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
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
        '/questions/category/$categoryId',
      );
      final apiResponse = ApiResponse<List<QuestionModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => (json as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(QuestionModel.fromJson)
            .toList(growable: false),
      );

      if (!apiResponse.succeeded) {
        throw ApiException(
          message: apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      final questions = apiResponse.data ?? const <QuestionModel>[];
      return PagedList<QuestionModel>(
        items: questions,
        pageNumber: pageNumber,
        totalPages: questions.isEmpty ? 0 : 1,
        totalCount: questions.length,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
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
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> createQuestion(QuestionModel question) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/questions',
        data: question.toCreateJson(),
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
  Future<bool> voteQuestion(String id, int type) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/votes/question/$id',
        queryParameters: <String, dynamic>{'type': type},
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
      throw _mapDioException(error);
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
      throw _mapDioException(error);
    }
  }

  @override
  Future<bool> saveQuestion(String questionId, String userId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/saved-questions/add',
        data: <String, dynamic>{'questionId': questionId, 'userId': userId},
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
  Future<bool> unsaveQuestion(String savedQuestionId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/saved-questions/remove/$savedQuestionId',
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
  Future<List<SavedQuestionModel>> getSavedQuestions() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user/saved-questions/by-user-Id',
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
      throw _mapDioException(error);
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
