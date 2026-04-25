import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/category_questions_controller.dart';
import '../widgets/question_card.dart';

class CategoryQuestionsScreen extends ConsumerWidget {
  const CategoryQuestionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryQuestionsControllerProvider(categoryId));
    final colors = context.dalleniColors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: CommonGlassAppBar(title: categoryName),
      body: state.isLoading
          ? const AppLoadingState()
          : state.errorMessage != null
          ? AppErrorState(
              message: state.errorMessage!,
              onRetry: () => ref
                  .read(
                    categoryQuestionsControllerProvider(categoryId).notifier,
                  )
                  .refresh(),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(
                    categoryQuestionsControllerProvider(categoryId).notifier,
                  )
                  .refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  top: kToolbarHeight + 40,
                  bottom: 40,
                  left: 16,
                  right: 16,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final question = state.questions[index];
                  return QuestionCard(
                    question: question,
                    onUpvote: () => ref
                        .read(
                          categoryQuestionsControllerProvider(
                            categoryId,
                          ).notifier,
                        )
                        .upvoteQuestion(question.id),
                    onDownvote: () => ref
                        .read(
                          categoryQuestionsControllerProvider(
                            categoryId,
                          ).notifier,
                        )
                        .downvoteQuestion(question.id),
                    onCategoryTap: (id, name) {
                      // Already in category view, if it's a different one, push new
                      if (id != categoryId) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryQuestionsScreen(
                              categoryId: id,
                              categoryName: name,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}
