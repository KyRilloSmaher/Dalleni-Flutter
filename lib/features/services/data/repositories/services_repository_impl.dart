import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/paged_list.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_data_source.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl({required ServicesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ServicesRemoteDataSource _remoteDataSource;

  @override
  Future<PagedList<ServiceEntity>> getServices({
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getServices(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<Either<Failure, List<Service>>> searchServices(String keyword) async {
    try {
      final services = await _remoteDataSource.searchServices(keyword);
      return Right(services);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// ─── Riverpod Providers ──────────────────────────────────────────────────────

final servicesRemoteDataSourceProvider =
    Provider<ServicesRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ServicesRemoteDataSourceImpl(dio);
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final remoteDataSource = ref.watch(servicesRemoteDataSourceProvider);
  return ServicesRepositoryImpl(remoteDataSource: remoteDataSource);
});
