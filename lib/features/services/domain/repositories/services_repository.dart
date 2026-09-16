import '../../../../core/error/either.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/paged_list.dart';
import '../entities/service_entity.dart';

abstract class ServicesRepository {
  Future<PagedList<ServiceEntity>> getServices({
    int pageNumber = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, List<Service>>> searchServices(String keyword);
}
