import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class AskHeader extends StatelessWidget {
  const AskHeader({
    required this.colors,
    required this.theme,
  });

  final DalleniColors colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ask a question',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Share your question and get help from the community.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}