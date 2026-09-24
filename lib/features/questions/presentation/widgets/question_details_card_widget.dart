import 'package:flutter/material.dart';

import '../../domain/entities/question_entity.dart';
import '../screens/category_questions_screen.dart';
import 'question_card.dart';

class QuestionDetailsCardWidget extends StatelessWidget {
  const QuestionDetailsCardWidget({
    super.key,
    required this.question,
    required this.onUpvote,
    required this.onDownvote,
  });

  final Question question;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Hero(
        tag: 'question_${question.id}',
        child: QuestionCard(
          isdetailsscreen: true,
          question: question,
          isDetailsView: true,
          onUpvote: onUpvote,
          onDownvote: onDownvote,
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
        ),
      ),
    );
  }
}
