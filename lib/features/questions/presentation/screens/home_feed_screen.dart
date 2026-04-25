import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/home_feed_controller.dart';
import '../widgets/question_card.dart';
import 'category_questions_screen.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

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

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(title: context.l10n.translate('homeFeedTitle')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              const SliverPadding(
                padding: EdgeInsets.only(top: kToolbarHeight + 32),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.l10n.translate('homeFeedSubtitle'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _searchController,
                        labelText: context.l10n.translate('homeSearchLabel'),
                        hintText: context.l10n.translate('homeSearchHint'),
                        prefixIcon: const Icon(Icons.search_rounded),
                        onChanged: controller.updateSearchQuery,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _TagFilterBar(
                    selectedTagId: state.selectedTag?.id,
                    tags: state.availableTags,
                    onTagSelected: (tag) => controller.selectTag(tag),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 16)),
              if (state.isLoading && state.questions.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppLoadingState(),
                )
              else if (state.errorMessage != null && state.questions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    message: state.errorMessage!,
                    onRetry: controller.refresh,
                  ),
                )
              else if (state.showEmptyState)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: context.l10n.translate('homeEmptyTitle'),
                    subtitle: context.l10n.translate('homeEmptySubtitle'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= state.questions.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final question = state.questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: QuestionCard(
                            question: question,
                            isSaved: state.savedQuestionIds.contains(
                              question.id,
                            ),
                            onUpvote: () =>
                                controller.upvoteQuestion(question.id),
                            onDownvote: () =>
                                controller.downvoteQuestion(question.id),
                            onSaveToggle: () =>
                                controller.toggleSaveQuestion(question),
                            onCategoryTap: (categoryId, categoryName) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CategoryQuestionsScreen(
                                    categoryId: categoryId,
                                    categoryName: categoryName,
                                  ),
                                ),
                              );
                            },
                            onTagTap: controller.selectTag,
                          ),
                        );
                      },
                      childCount:
                          state.questions.length +
                          (state.isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagFilterBar extends StatelessWidget {
  const _TagFilterBar({
    required this.selectedTagId,
    required this.tags,
    required this.onTagSelected,
  });

  final String? selectedTagId;
  final List<QuestionTag> tags;
  final ValueChanged<QuestionTag?> onTagSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isAllOption = index == 0;
          final isSelected = isAllOption
              ? selectedTagId == null
              : tags[index - 1].id == selectedTagId;
          final label = isAllOption
              ? context.l10n.translate('homeAllTags')
              : tags[index - 1].name;

          return ChoiceChip(
            selected: isSelected,
            label: Text(label),
            onSelected: (_) =>
                onTagSelected(isAllOption ? null : tags[index - 1]),
            selectedColor: colors.primaryContainer,
            backgroundColor: colors.surfaceContainerHigh,
            side: BorderSide(
              color: isSelected ? colors.primary : colors.outlineVariant,
            ),
            labelStyle: textTheme.labelLarge?.copyWith(
              color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }
}
