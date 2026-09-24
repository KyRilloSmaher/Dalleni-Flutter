import 'package:dalleni/features/official_entities/data/models/service_model.dart';
import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/models/paged_list.dart';
import '../../../../core/network/api_exception.dart';

import '../models/official_entity_model.dart';

abstract class OfficialEntitiesRemoteDataSource {
  Future<PagedList<OfficialEntityModel>> getOfficialEntities({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<OfficialEntityModel> getOfficialEntity(String id);

  Future<List<ServiceModel>> getOfficialEntityServices(String officialEntityId);
}

class OfficialEntitiesRemoteDataSourceImpl
    implements OfficialEntitiesRemoteDataSource {
  OfficialEntitiesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedList<OfficialEntityModel>> getOfficialEntities({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/official-entities',
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': pageSize,
        },
      );

      final responseData = response.data ?? <String, dynamic>{};

      return _parsePagedOfficialEntities(responseData);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<OfficialEntityModel> getOfficialEntity(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/official-entities/$id',
      );
      final responseData = response.data ?? <String, dynamic>{};

      if (responseData.containsKey('data') && responseData['data'] != null) {
        final apiResponse = ApiResponse<OfficialEntityModel>.fromJson(
          responseData,
          fromJsonT: (json) =>
              OfficialEntityModel.fromJson(json as Map<String, dynamic>),
        );

        if (!apiResponse.succeeded || apiResponse.data == null) {
          throw ApiException(
            message: apiResponse.message.isEmpty
                ? 'Failed to fetch official entity.'
                : apiResponse.message,
            statusCode: apiResponse.statusCode,
          );
        }

        return apiResponse.data!;
      }

      return OfficialEntityModel.fromJson(responseData);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<ServiceModel>> getOfficialEntityServices(
    String officialEntityId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/services/official-entity/$officialEntityId',
      );

      final rawData = response.data;

      if (rawData is Map<String, dynamic>) {
        if (rawData.containsKey('data')) {
          final data = rawData['data'];
          if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(ServiceModel.fromJson)
                .toList(growable: false);
          } else if (data is Map<String, dynamic> &&
              data.containsKey('items')) {
            final items = data['items'] as List<dynamic>? ?? [];
            return items
                .whereType<Map<String, dynamic>>()
                .map(ServiceModel.fromJson)
                .toList(growable: false);
          }
        } else if (rawData.containsKey('items')) {
          final items = rawData['items'] as List<dynamic>? ?? [];
          return items
              .whereType<Map<String, dynamic>>()
              .map(ServiceModel.fromJson)
              .toList(growable: false);
        }
      } else if (rawData is List) {
        return rawData
            .whereType<Map<String, dynamic>>()
            .map(ServiceModel.fromJson)
            .toList(growable: false);
      }

      return const <ServiceModel>[];
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  PagedList<OfficialEntityModel> _parsePagedOfficialEntities(
    Map<String, dynamic> responseData,
  ) {
    if (responseData.containsKey('items')) {
      return PagedList<OfficialEntityModel>.fromJson(
        responseData,
        (item) => OfficialEntityModel.fromJson(item as Map<String, dynamic>),
      );
    }

    final apiResponse = ApiResponse<PagedList<OfficialEntityModel>>.fromJson(
      responseData,
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          return PagedList<OfficialEntityModel>.fromJson(
            json,
            (item) =>
                OfficialEntityModel.fromJson(item as Map<String, dynamic>),
          );
        }
        return const PagedList<OfficialEntityModel>(
          items: [],
          pageNumber: 1,
          totalPages: 0,
          totalCount: 0,
          hasPreviousPage: false,
          hasNextPage: false,
        );
      },
    );

    if (!apiResponse.succeeded) {
      throw ApiException(
        message: apiResponse.message.isEmpty
            ? 'Failed to fetch official entities.'
            : apiResponse.message,
        statusCode: apiResponse.statusCode,
      );
    }

    return apiResponse.data ??
        const PagedList<OfficialEntityModel>(
          items: [],
          pageNumber: 1,
          totalPages: 0,
          totalCount: 0,
          hasPreviousPage: false,
          hasNextPage: false,
        );
  }
}
