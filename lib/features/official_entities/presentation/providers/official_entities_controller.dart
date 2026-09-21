import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/official_entities_repository_impl.dart';
import '../../domain/entities/official_entity.dart';

class OfficialEntitiesState {
  const OfficialEntitiesState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.entities,
    required this.currentPage,
    required this.hasMore,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final List<OfficialEntity> entities;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  factory OfficialEntitiesState.initial() {
    return const OfficialEntitiesState(
      isLoading: true,
      isLoadingMore: false,
      entities: <OfficialEntity>[],
      currentPage: 1,
      hasMore: true,
    );
  }

  bool get showEmptyState =>
      !isLoading && entities.isEmpty && errorMessage == null;

  OfficialEntitiesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<OfficialEntity>? entities,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OfficialEntitiesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      entities: entities ?? this.entities,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class OfficialEntitiesController extends Notifier<OfficialEntitiesState> {
  static const int _pageSize = 10;
  bool _isBootstrapping = false;

  @override
  OfficialEntitiesState build() {
    Future.microtask(_bootstrap);
    return OfficialEntitiesState.initial();
  }

  Future<void> _bootstrap() async {
    if (_isBootstrapping) {
      return;
    }
    _isBootstrapping = true;
    try {
      await refresh();
    } finally {
      _isBootstrapping = false;
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      currentPage: 1,
      hasMore: true,
      clearError: true,
    );

    try {
      final pagedEntities = await ref
          .read(officialEntitiesRepositoryProvider)
          .getOfficialEntities(pageNumber: 1, pageSize: _pageSize);

      state = state.copyWith(
        isLoading: false,
        entities: pagedEntities.items,
        currentPage: pagedEntities.pageNumber,
        hasMore: pagedEntities.hasNextPage,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = state.currentPage + 1;
      final pagedEntities = await ref
          .read(officialEntitiesRepositoryProvider)
          .getOfficialEntities(pageNumber: nextPage, pageSize: _pageSize);

      state = state.copyWith(
        isLoadingMore: false,
        entities: <OfficialEntity>[...state.entities, ...pagedEntities.items],
        currentPage: pagedEntities.pageNumber,
        hasMore: pagedEntities.hasNextPage,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }
}

final officialEntitiesControllerProvider =
    NotifierProvider<OfficialEntitiesController, OfficialEntitiesState>(
      OfficialEntitiesController.new,
    );
