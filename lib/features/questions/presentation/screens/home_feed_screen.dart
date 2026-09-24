import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/home_feed_controller.dart';
import '../widgets/home_feed_empty_widget.dart';
import '../widgets/home_feed_error_widget.dart';
import '../widgets/home_feed_filter_section.dart';
import '../widgets/home_feed_loading_widget.dart';
import '../widgets/home_feed_search_bar_widget.dart';
import '../widgets/home_feed_success_widget.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeFeedControllerProvider);
    final colors = context.dalleniColors;
    final controller = ref.read(homeFeedControllerProvider.notifier);

    if (_searchController.text != state.searchQuery) {
      _searchController.value = TextEditingValue(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    final showSearchField =
        state.isSearchExpanded || state.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(
        title: context.l10n.translate('homeFeedTitle'),
        trailingActions: <Widget>[
          IconButton(
            icon: Icon(
              showSearchField
                  ? Icons.search_off_rounded
                  : Icons.search_rounded,
              color: colors.onSurface,
            ),
            tooltip: context.l10n.translate('homeSearchLabel'),
            onPressed: controller.toggleSearchExpanded,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: colors.primary,
              backgroundColor: colors.surface,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollDetails) {
                  if (scrollDetails.metrics.pixels >=
                      scrollDetails.metrics.maxScrollExtent - 240) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    const SliverPadding(
                      padding: EdgeInsets.only(top: kToolbarHeight + 16),
                    ),
                    if (showSearchField)
                      HomeFeedSearchBarWidget(
                        controller: _searchController,
                        searchQuery: state.searchQuery,
                        onSearchChanged: controller.updateSearchQuery,
                        onClearSearch: () => controller.updateSearchQuery(''),
                      ),
                    HomeFeedFilterSection(
                      selectedCategoryId: state.selectedCategory?.id,
                      categories: state.availablecategory,
                      onCategorySelected: controller.selectCategory,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 8,
                        color: colors.surfaceContainerLow,
                      ),
                    ),
                    if (state.isLoading && state.questions.isEmpty)
                      const HomeFeedLoadingWidget()
                    else if (state.errorMessage != null &&
                        state.questions.isEmpty)
                      HomeFeedErrorWidget(
                        errorMessage: state.errorMessage!,
                        onRetry: controller.refresh,
                      )
                    else if (state.showEmptyState)
                      HomeFeedEmptyWidget(
                        selectedCategory: state.selectedCategory,
                        onClearFilter: () => controller.selectCategory(null),
                      )
                    else
                      HomeFeedSuccessWidget(
                        questions: state.questions,
                        savedQuestionIds: state.savedQuestionIds,
                        areSavedQuestionsReady: state.areSavedQuestionsReady,
                        isLoadingMore: state.isLoadingMore,
                        onUpvote: controller.upvoteQuestion,
                        onDownvote: controller.downvoteQuestion,
                        onSaveToggle: controller.toggleSaveQuestion,
                        onTagTap: controller.selecttag,
                      ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
