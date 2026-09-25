import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/category_questions_controller.dart';
import '../widgets/category_questions_error_widget.dart';
import '../widgets/category_questions_loading_widget.dart';
import '../widgets/category_questions_success_widget.dart';

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
    final controller = ref.read(
      categoryQuestionsControllerProvider(categoryId).notifier,
    );
    final colors = context.dalleniColors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: CommonGlassAppBar(title: categoryName),
      body: state.isLoading
          ? const CategoryQuestionsLoadingWidget()
          : state.errorMessage != null
              ? CategoryQuestionsErrorWidget(
                  errorMessage: state.errorMessage!,
                  onRetry: controller.refresh,
                )
              : CategoryQuestionsSuccessWidget(
                  questions: state.questions,
                  categoryId: categoryId,
                  categoryName: categoryName,
                  onRefresh: controller.refresh,
                  onUpvote: controller.upvoteQuestion,
                  onDownvote: controller.downvoteQuestion,
                ),
    );
  }
}
