import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class QuestionDetailsAnswersHeaderWidget extends StatelessWidget {
  const QuestionDetailsAnswersHeaderWidget({
    super.key,
    required this.answersCount,
  });

  final int answersCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
        color: colors.surface,
        child: Row(
          children: [
            Text(
              'Answers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$answersCount',
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
