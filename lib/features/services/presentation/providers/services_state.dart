import 'package:dalleni/features/services/domain/entities/service_entity.dart';

class ServicesState {
  const ServicesState({
    required this.isLoading,
    this.errorMessage,
    required this.services,
    this.categories = const [],
    this.quickAccessItems = const [],
    this.featuredCategory,
    this.searchQuery = '',
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ServiceEntity> services;
  final List<ServiceCategory> categories;
  final List<QuickAccessItem> quickAccessItems;
  final FeaturedCategory? featuredCategory;
  final String searchQuery;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  factory ServicesState.initial() => const ServicesState(
        isLoading: true,
        services: [],
        categories: [],
        quickAccessItems: [],
        searchQuery: '',
      );

  ServicesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceEntity>? services,
    List<ServiceCategory>? categories,
    List<QuickAccessItem>? quickAccessItems,
    FeaturedCategory? featuredCategory,
    String? searchQuery,
    bool clearError = false,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      quickAccessItems: quickAccessItems ?? this.quickAccessItems,
      featuredCategory: featuredCategory ?? this.featuredCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
