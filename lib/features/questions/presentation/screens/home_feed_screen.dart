import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/home_feed_controller.dart';
import '../widgets/fb_post_card.dart';
import '../widgets/fb_post_skeleton.dart';
import '../widgets/tag_filter_bar.dart';
import 'category_questions_screen.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(homeFeedControllerProvider.notifier).loadMore();
    }
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

    final showSearchField = _isSearchExpanded || state.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(
        title: context.l10n.translate('homeFeedTitle'),
        trailingActions: <Widget>[
          IconButton(
            icon: Icon(
              showSearchField ? Icons.search_off_rounded : Icons.search_rounded,
              color: colors.onSurface,
            ),
            tooltip: context.l10n.translate('homeSearchLabel'),
            onPressed: () {
              setState(() {
                _isSearchExpanded = !_isSearchExpanded;
                if (!_isSearchExpanded && state.searchQuery.isNotEmpty) {
                  controller.updateSearchQuery('');
                }
              });
            },
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
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  // Top padding offset for glass appbar
                  const SliverPadding(
                    padding: EdgeInsets.only(top: kToolbarHeight + 16),
                  ),

                  // Collapsible Modern Search Bar
                  if (showSearchField)
                    SliverToBoxAdapter(
                      child: Container(
                        color: colors.surface,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: AppTextField(
                          controller: _searchController,
                          labelText: context.l10n.translate('homeSearchLabel'),
                          hintText: context.l10n.translate('homeSearchHint'),
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () =>
                                      controller.updateSearchQuery(''),
                                )
                              : null,
                          onChanged: controller.updateSearchQuery,
                        ),
                      ),
                    ),

                  // Horizontal Tag Filter Bar Section
                  if (state.availableTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        color: colors.surface,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TagFilterBar(
                              selectedTagId: state.selectedTag?.id,
                              tags: state.availableTags,
                              onTagSelected: (tag) => controller.selectTag(tag),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Subtle feed gap between header filters & feed posts
                  SliverToBoxAdapter(
                    child: Container(
                      height: 8,
                      color: colors.surfaceContainerLow,
                    ),
                  ),

                  // Loading State (Shimmer Skeleton UI)
                  if (state.isLoading && state.questions.isEmpty)
                    const SliverToBoxAdapter(
                      child: FbFeedSkeletonList(count: 4),
                    )
                  // Error State
                  else if (state.errorMessage != null && state.questions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        color: colors.surface,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.error_outline_rounded,
                                size: 54,
                                color: colors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.translate('errorStateTitle'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: controller.refresh,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(
                                  context.l10n.translate('retryButton'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Empty Feed State
                  else if (state.showEmptyState)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        color: colors.surface,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.dynamic_feed_rounded,
                                size: 64,
                                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.translate('homeEmptyTitle'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.translate('homeEmptySubtitle'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              if (state.selectedTag != null) ...<Widget>[
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () => controller.selectTag(null),
                                  icon: const Icon(Icons.filter_alt_off_rounded),
                                  label: const Text('Clear Filter'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  // Main Facebook Feed Post List
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.questions.length) {
                            return Container(
                              color: colors.surface,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final question = state.questions[index];
                          final isLastItem = index == state.questions.length - 1;

                          return Column(
                            children: <Widget>[
                              FbPostCard(
                                question: question,
                                isSaved: state.savedQuestionIds.contains(
                                  question.id,
                                ),
                                onUpvote: () =>
                                    controller.upvoteQuestion(question.id),
                                onDownvote: () =>
                                    controller.downvoteQuestion(question.id),
                                onSaveToggle: !state.areSavedQuestionsReady
                                    ? null
                                    : () => controller.toggleSaveQuestion(
                                        question,
                                      ),
                                onCategoryTap: () {
                                  print("category id ${question.categoryId}");
                                  print("category name ${question.categoryName}");
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategoryQuestionsScreen(
                                        categoryId: question.categoryId??"",
                                        categoryName: question.categoryName??"",
                                      ),
                                    ),
                                  );
                                },
                                onTagTap: controller.selectTag,
                              ),
                   
                              if (!isLastItem || state.isLoadingMore)
                                Container(
                                  height: 8,
                                  color: colors.surfaceContainerLow,
                                ),
                            ],
                          );
                        },
                        childCount:
                            state.questions.length +
                            (state.isLoadingMore ? 1 : 0),
                      ),
                    ),

                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
