import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class QuestionStatsSection extends StatelessWidget {
  const QuestionStatsSection({
    super.key,
    required this.upVotes,
    required this.answersCount,
    required this.views,
  });

  final int upVotes;
  final int answersCount;
  final int views;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (upVotes > 0)
            Row(
              children: [
                CircleAvatar(
                  radius: 9,
                  backgroundColor: colors.primary,
                  child: const Icon(
                    Icons.thumb_up,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$upVotes',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          const Spacer(),
          Text(
            '$answersCount answers',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$views views',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
