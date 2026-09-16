import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../../../../core/models/paged_list.dart';
import '../../../../core/network/api_exception.dart';
import '../models/service_model.dart';

abstract class ServicesRemoteDataSource {
  Future<PagedList<ServiceModel>> getServices({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<List<ServiceModel>> searchServices(String keyword);
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  ServicesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedList<ServiceModel>> getServices({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/services',
        queryParameters: <String, dynamic>{
          'PageNumber': pageNumber,
          'PageSize': pageSize,
        },
      );

      final apiResponse = ApiResponse<PagedList<ServiceModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) => PagedList<ServiceModel>.fromJson(
          json as Map<String, dynamic>,
          (item) => ServiceModel.fromJson(item as Map<String, dynamic>),
        ),
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message.isEmpty
              ? 'Failed to fetch services.'
              : apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<List<ServiceModel>> searchServices(String keyword) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/services/search',
        queryParameters: <String, dynamic>{'keyword': keyword},
      );
      final apiResponse = ApiResponse<List<ServiceModel>>.fromJson(
        response.data ?? <String, dynamic>{},
        fromJsonT: (json) =>
            (json as List<dynamic>?)
                ?.map(
                  (item) => ServiceModel.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            <ServiceModel>[],
      );

      if (!apiResponse.succeeded || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message.isEmpty
              ? 'Failed to search services.'
              : apiResponse.message,
          statusCode: apiResponse.statusCode,
        );
      }

      return apiResponse.data!;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
