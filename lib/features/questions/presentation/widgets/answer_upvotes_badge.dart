import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class AnswerUpvotesBadge extends StatelessWidget {
  const AnswerUpvotesBadge({
    super.key,
    required this.upvotes,
  });

  final int upvotes;

  @override
  Widget build(BuildContext context) {
    if (upvotes == 0) return const SizedBox.shrink();

    final colors = context.dalleniColors;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.thumb_up, size: 13, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            '$upvotes',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
