import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class AnswerContentBubble extends StatelessWidget {
  const AnswerContentBubble({
    super.key,
    required this.authorName,
    required this.content,
  });

  final String authorName;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            authorName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: colors.onSurface,
              height: 1.45,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
