import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import 'answer_actions_bar.dart';
import 'answer_author_avatar.dart';
import 'answer_content_bubble.dart';
import 'answer_upvotes_badge.dart';

class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    required this.answer,
    required this.isUpvoted,
    required this.isDownvoted,
    required this.isMarked,
    required this.isQuestionOwner,
    required this.onUpvote,
    required this.onDownvote,
    required this.onDelete,
    required this.onToggleAccept,
    required this.onToggleMark,
  });

  final Answer answer;

  final bool isUpvoted;
  final bool isDownvoted;
  final bool isMarked;
  final bool isQuestionOwner;

  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onDelete;
  final VoidCallback onToggleAccept;
  final VoidCallback onToggleMark;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnswerAuthorAvatar(
                imageUrl: answer.authorProfileImageUrl,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnswerContentBubble(
                      authorName: answer.authorName,
                      content: answer.content,
                    ),

                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AnswerActionsBar(
                        timestamp: answer.timestamp,
                        isUpvoted: isUpvoted,
                        isDownvoted: isDownvoted,
                        isMarked: isMarked,
                        isApproved: answer.isApproved,
                        isQuestionOwner: isQuestionOwner,
                        onUpvote: onUpvote,
                        onDownvote: onDownvote,
                        onDelete: onDelete,
                        onToggleAccept: onToggleAccept,
                        onToggleMark: onToggleMark,
                      ),
                    ),

                    AnswerUpvotesBadge(
                      upvotes: answer.upVotes,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(
            height: 1,
            color: colors.outlineVariant,
          ),
        ],
      ),
    );
  }
}