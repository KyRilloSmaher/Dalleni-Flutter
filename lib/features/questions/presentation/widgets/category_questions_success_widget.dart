import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/question_entity.dart';
import '../providers/saved_questions_controller.dart';
import '../screens/category_questions_screen.dart';
import 'category_questions_empty_widget.dart';
import 'question_card.dart';

class CategoryQuestionsSuccessWidget extends ConsumerWidget {
  const CategoryQuestionsSuccessWidget({
    super.key,
    required this.questions,
    required this.categoryId,
    required this.categoryName,
    required this.onRefresh,
    required this.onUpvote,
    required this.onDownvote,
  });

  final List<Question> questions;
  final String categoryId;
  final String categoryName;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onUpvote;
  final ValueChanged<String> onDownvote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (questions.isEmpty) {
      return CategoryQuestionsEmptyWidget(categoryName: categoryName);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 40,
          left: 16,
          right: 16,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final question = questions[index];
          final isSaved = ref.watch(
            savedQuestionsControllerProvider.select(
              (s) => s.savedRecordIds.containsKey(question.id),
            ),
          );

          return QuestionCard(
            isdetailsscreen: false,
            question: question,
            isSaved: isSaved,
            onSaveToggle: () => ref
                .read(savedQuestionsControllerProvider.notifier)
                .toggleSave(question),
            onUpvote: () => onUpvote(question.id),
            onDownvote: () => onDownvote(question.id),
            onCategoryTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryQuestionsScreen(
                    categoryId: categoryId,
                    categoryName: categoryName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
