import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import 'fb_post_card.dart';

class QuestionActionsSection extends StatelessWidget {
  const QuestionActionsSection({
    super.key,
    required this.isUpvoted,
    required this.isDownvoted,
    this.onUpvote,
    this.onDownvote,
  });

  final bool isUpvoted;
  final bool isDownvoted;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: FbActionButton(
              icon: Icons.thumb_up_alt_outlined,
              activeIcon: Icons.thumb_up_alt_rounded,
              label: 'Upvote',
              isActive: isUpvoted,
              activeColor: colors.primary,
              onPressed: onUpvote,
            ),
          ),
          Expanded(
            child: FbActionButton(
              icon: Icons.thumb_down_alt_outlined,
              activeIcon: Icons.thumb_down_alt_rounded,
              label: 'Downvote',
              isActive: isDownvoted,
              activeColor: colors.error,
              onPressed: onDownvote,
            ),
          ),
        ],
      ),
    );
  }
}
