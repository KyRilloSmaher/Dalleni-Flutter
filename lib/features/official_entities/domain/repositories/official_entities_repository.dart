import 'package:dalleni/features/official_entities/domain/entities/service_entity.dart';
import '../../../../core/models/paged_list.dart';
import '../entities/official_entity.dart';

abstract class OfficialEntitiesRepository {
  Future<PagedList<OfficialEntity>> getOfficialEntities({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<OfficialEntity> getOfficialEntity(String id);

  Future<List<Service>> getOfficialEntityServices(String officialEntityId);
}
