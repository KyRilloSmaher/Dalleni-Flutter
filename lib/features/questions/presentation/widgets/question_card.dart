import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import '../screens/question_details_screen.dart';
import 'question_actions_section.dart';
import 'question_content.dart';
import 'question_header.dart';
import 'question_stats_section.dart';
import 'question_tags_section.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.isDetailsView = false,
    this.isSaved = false,
    this.onUpvote,
    this.onDownvote,
    this.onSaveToggle,
    this.onCategoryTap,
    this.onTagTap,
    required this.isdetailsscreen,
  });

  final Question question;
  final bool isDetailsView;
  final bool isSaved;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onSaveToggle;
  final bool isdetailsscreen;
  final VoidCallback? onCategoryTap;
  final void Function(QuestionTag tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final isUpvoted = question.upVotedByCurrentUser;
    final isDownvoted = question.downVotedByCurrentUser;

    final createdAtLabel = DateFormat.yMMMd().add_jm().format(
          question.createdAt.toLocal(),
        );

    return GestureDetector(
      onTap: () {
        if (!isdetailsscreen) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QuestionDetailsScreen(question: question),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionHeader(
              authorName: question.authorName,
              authorProfileImageUrl: question.authorProfileImageUrl,
              createdAtLabel: createdAtLabel,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: isDetailsView
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                QuestionDetailsScreen(question: question),
                          ),
                        );
                      },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionContent(
                      title: question.title,
                      content: question.content,
                      isDetailsView: isDetailsView,
                    ),
                    QuestionTagsSection(
                      categoryId: question.categoryId,
                      categoryName: question.categoryName,
                      tags: question.tags,
                      onCategoryTap: onCategoryTap,
                      onTagTap: onTagTap,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            QuestionStatsSection(
              upVotes: question.upVotes,
              answersCount: question.answersCount,
              views: question.views,
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: colors.outlineVariant),
            QuestionActionsSection(
              isUpvoted: isUpvoted,
              isDownvoted: isDownvoted,
              onUpvote: onUpvote,
              onDownvote: onDownvote,
            ),
            Container(height: 8, color: colors.surfaceContainerLowest),
          ],
        ),
      ),
    );
  }
}
