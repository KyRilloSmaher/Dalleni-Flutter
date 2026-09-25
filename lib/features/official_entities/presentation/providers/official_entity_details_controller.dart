import 'package:dalleni/features/official_entities/domain/entities/service_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/official_entities_repository_impl.dart';
import '../../domain/entities/official_entity.dart';

class OfficialEntityDetailsState {
  const OfficialEntityDetailsState({
    required this.isLoading,
    this.entity,
    this.services = const <Service>[],
    this.errorMessage,
  });

  final bool isLoading;
  final OfficialEntity? entity;
  final List<Service> services;
  final String? errorMessage;

  factory OfficialEntityDetailsState.initial([OfficialEntity? initialEntity]) {
    return OfficialEntityDetailsState(
      isLoading: true,
      entity: initialEntity,
      services: const <Service>[],
    );
  }

  OfficialEntityDetailsState copyWith({
    bool? isLoading,
    OfficialEntity? entity,
    List<Service>? services,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OfficialEntityDetailsState(
      isLoading: isLoading ?? this.isLoading,
      entity: entity ?? this.entity,
      services: services ?? this.services,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class OfficialEntityDetailsController
    extends AutoDisposeFamilyNotifier<OfficialEntityDetailsState, String> {
  @override
  OfficialEntityDetailsState build(String arg) {
    Future.microtask(() => loadDetails(arg));
    return OfficialEntityDetailsState.initial();
  }

  Future<void> loadDetails(String entityId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(officialEntitiesRepositoryProvider);
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        repository.getOfficialEntity(entityId),
        repository.getOfficialEntityServices(entityId),
      ]);

      final fetchedEntity = results[0] as OfficialEntity;
      final fetchedServices = results[1] as List<Service>;

      state = state.copyWith(
        isLoading: false,
        entity: fetchedEntity,
        services: fetchedServices,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> refresh() => loadDetails(arg);
}

final officialEntityDetailsControllerProvider = NotifierProvider.autoDispose
    .family<
      OfficialEntityDetailsController,
      OfficialEntityDetailsState,
      String
    >(OfficialEntityDetailsController.new);
