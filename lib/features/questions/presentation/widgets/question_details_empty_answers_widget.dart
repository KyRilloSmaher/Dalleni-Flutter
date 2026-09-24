import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class QuestionDetailsEmptyAnswersWidget extends StatelessWidget {
  const QuestionDetailsEmptyAnswersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 20,
        ),
        color: colors.surface,
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 44,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No answers yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first one to answer this question.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
