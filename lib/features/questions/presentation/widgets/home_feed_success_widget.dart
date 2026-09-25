import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import '../screens/category_questions_screen.dart';
import 'fb_post_card.dart';

class HomeFeedSuccessWidget extends StatelessWidget {
  const HomeFeedSuccessWidget({
    super.key,
    required this.questions,
    required this.savedQuestionIds,
    required this.areSavedQuestionsReady,
    required this.isLoadingMore,
    required this.onUpvote,
    required this.onDownvote,
    required this.onSaveToggle,
    required this.onTagTap,
  });

  final List<Question> questions;
  final Set<String> savedQuestionIds;
  final bool areSavedQuestionsReady;
  final bool isLoadingMore;
  final ValueChanged<String> onUpvote;
  final ValueChanged<String> onDownvote;
  final ValueChanged<Question> onSaveToggle;
  final ValueChanged<QuestionTag?> onTagTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= questions.length) {
            return Container(
              color: colors.surface,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final question = questions[index];
          final isLastItem = index == questions.length - 1;

          return Column(
            children: <Widget>[
            FbPostCard(
              isDetailsView: false,
                question: question,
                isSaved: savedQuestionIds.contains(question.id),
                onUpvote: () => onUpvote(question.id),
                onDownvote: () => onDownvote(question.id),
                onSaveToggle: !areSavedQuestionsReady
                    ? null
                    : () => onSaveToggle(question),
                onCategoryTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryQuestionsScreen(
                        categoryId: question.categoryId ?? "",
                        categoryName: question.categoryName ?? "",
                      ),
                    ),
                  );
                },
                onTagTap: onTagTap,
              ),
              if (!isLastItem || isLoadingMore)
              Container(height: 8, color: colors.surfaceContainerLow),
            ],
          );
      }, childCount: questions.length + (isLoadingMore ? 1 : 0)),
    );
  }
}
