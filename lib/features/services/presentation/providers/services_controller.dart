import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_entity.dart';

class ServicesState {
  const ServicesState({
    required this.isLoading,
    this.errorMessage,
    required this.categories,
    required this.quickAccessItems,
    this.featuredCategory,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ServiceCategory> categories;
  final List<QuickAccessItem> quickAccessItems;
  final FeaturedCategory? featuredCategory;

  factory ServicesState.initial() => const ServicesState(
    isLoading: true,
    categories: [],
    quickAccessItems: [],
  );

  ServicesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ServiceCategory>? categories,
    List<QuickAccessItem>? quickAccessItems,
    FeaturedCategory? featuredCategory,
    bool clearError = false,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      quickAccessItems: quickAccessItems ?? this.quickAccessItems,
      featuredCategory: featuredCategory ?? this.featuredCategory,
    );
  }
}

class ServicesController extends Notifier<ServicesState> {
  @override
  ServicesState build() {
    Future.microtask(_fetchServices);
    return ServicesState.initial();
  }

  Future<void> _fetchServices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Simulate network request
      await Future<void>.delayed(const Duration(seconds: 2));

      // MOCK DATA: Notice null fields scattered to test UI graceful fallbacks
      final mockCategories = [
        const ServiceCategory(
          id: '1',
          name: 'Traffic Department', // Provided
          description: null, // Null description
        ),
        const ServiceCategory(
          id: '2',
          name: null, // Null name
          description: 'Apply for residential electricity meter',
        ),
        const ServiceCategory(
          id: '3',
          name: 'Business Licensing',
          description: 'Start your new business correctly',
          iconPath: 'has_icon_path.png', // Simulated icon
        ),
      ];

      final mockQuickAccess = [
        const QuickAccessItem(id: '1', title: 'Pay Violations', subtitle: null),
        const QuickAccessItem(
          id: '2',
          title: null,
          subtitle: 'Valid until 2029',
        ),
      ];

      final mockFeatured = const FeaturedCategory(
        id: '1',
        title: null, // Null title
        tags: ['Trending', 'Essential'],
        imagePath: null,
      );

      state = state.copyWith(
        isLoading: false,
        categories: mockCategories,
        quickAccessItems: mockQuickAccess,
        featuredCategory: mockFeatured,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load services.',
      );
    }
  }

  Future<void> refresh() => _fetchServices();
}

final servicesControllerProvider =
    NotifierProvider<ServicesController, ServicesState>(ServicesController.new);
