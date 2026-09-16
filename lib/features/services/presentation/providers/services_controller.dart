import 'package:dalleni/features/services/presentation/providers/services_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/entities/service_entity.dart';


class ServicesController extends Notifier<ServicesState> {
  @override
  ServicesState build() {
    Future.microtask(() => _fetchServices());
    return ServicesState.initial();
  }

  Future<void> _fetchServices({int pageNumber = 1, int pageSize = 10}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repository = ref.read(servicesRepositoryProvider);
      final pagedServices = await repository.getServices(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      final servicesList = pagedServices.items;
      _updateStateWithServices(servicesList);
    } catch (e) {
      final message =
          e is ApiException ? e.message : 'Failed to load services.';
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    }
  }

  Future<void> searchServices(String keyword) async {
    final trimmedKeyword = keyword.trim();
    if (trimmedKeyword.isEmpty) {
      state = state.copyWith(searchQuery: '');
      return _fetchServices();
    }

    state = state.copyWith(
      isLoading: true,
      searchQuery: trimmedKeyword,
      clearError: true,
    );

    final repository = ref.read(servicesRepositoryProvider);
    final result = await repository.searchServices(trimmedKeyword);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          services: [],
        );
      },
      (servicesList) {
        _updateStateWithServices(
          servicesList,
          searchQuery: trimmedKeyword,
        );
      },
    );
  }

  void _updateStateWithServices(
    List<ServiceEntity> servicesList, {
    String? searchQuery,
  }) {
    state = state.copyWith(
      isLoading: false,
      services: servicesList,
      searchQuery: searchQuery ?? state.searchQuery,
      clearError: true,
    );
  }

  Future<void> clearSearch() async {
    state = state.copyWith(searchQuery: '');
    await _fetchServices();
  }

  Future<void> refresh() {
    if (state.isSearching) {
      return searchServices(state.searchQuery);
    }
    return _fetchServices();
  }
}

final servicesControllerProvider =
    NotifierProvider<ServicesController, ServicesState>(
        ServicesController.new);
