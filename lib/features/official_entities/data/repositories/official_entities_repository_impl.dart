import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/paged_list.dart';
import '../../../../core/network/dio_client.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../domain/entities/official_entity.dart';
import '../../domain/repositories/official_entities_repository.dart';
import '../datasources/official_entities_remote_data_source.dart';

class OfficialEntitiesRepositoryImpl implements OfficialEntitiesRepository {
  OfficialEntitiesRepositoryImpl({
    required OfficialEntitiesRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final OfficialEntitiesRemoteDataSource _remoteDataSource;

  @override
  Future<PagedList<OfficialEntity>> getOfficialEntities({
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getOfficialEntities(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<OfficialEntity> getOfficialEntity(String id) {
    return _remoteDataSource.getOfficialEntity(id);
  }

  @override
  Future<List<Service>> getOfficialEntityServices(String officialEntityId) {
    return _remoteDataSource.getOfficialEntityServices(officialEntityId);
  }
}

// ─── Riverpod Providers ──────────────────────────────────────────────────────

final officialEntitiesRemoteDataSourceProvider =
    Provider<OfficialEntitiesRemoteDataSource>((ref) {
      final dio = ref.watch(dioClientProvider);
      return OfficialEntitiesRemoteDataSourceImpl(dio);
    });

final officialEntitiesRepositoryProvider = Provider<OfficialEntitiesRepository>(
  (ref) {
    final remoteDataSource = ref.watch(
      officialEntitiesRemoteDataSourceProvider,
    );
    return OfficialEntitiesRepositoryImpl(remoteDataSource: remoteDataSource);
  },
);
