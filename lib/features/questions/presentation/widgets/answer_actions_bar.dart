import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/dalleni_theme.dart';
import 'common_action.dart';

class AnswerActionsBar extends StatelessWidget {
  const AnswerActionsBar({
    super.key,
    required this.timestamp,
    required this.isUpvoted,
    required this.isDownvoted,
    required this.isMarked,
    required this.isApproved,
    required this.isQuestionOwner,
    this.onUpvote,
    this.onDownvote,
    this.onDelete,
    this.onToggleAccept,
    this.onToggleMark,
  });

  final DateTime timestamp;
  final bool isUpvoted;
  final bool isDownvoted;
  final bool isMarked;
  final bool isApproved;
  final bool isQuestionOwner;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAccept;
  final VoidCallback? onToggleMark;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Row(
      children: [
        Text(
          intl.DateFormat.MMMd().format(timestamp),
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        CommentAction(
          label: 'Upvote',
          isActive: isUpvoted,
          activeColor: Colors.deepOrange,
          onTap: onUpvote ?? () {},
        ),
        const SizedBox(width: 12),
        CommentAction(
          label: 'Downvote',
          isActive: isDownvoted,
          activeColor: Colors.blue,
          onTap: onDownvote ?? () {},
        ),
        const SizedBox(width: 12),
        CommentAction(
          label: 'Delete',
          isActive: false,
          activeColor: colors.error,
          onTap: onDelete ?? () {},
        ),
        if (isQuestionOwner) ...[
          const SizedBox(width: 12),
          CommentAction(
            label: isApproved ? 'Unaccept' : 'Accept',
            isActive: isApproved,
            activeColor: colors.secondary,
            onTap: onToggleAccept ?? () {},
          ),
        ] else ...[
          const SizedBox(width: 12),
          CommentAction(
            label: isMarked ? 'Unmark' : 'Mark',
            isActive: isMarked,
            activeColor: colors.secondary,
            onTap: onToggleMark ?? () {},
          ),
        ],
        const Spacer(),
        if (isApproved)
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 15,
                color: colors.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Approved',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.secondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
