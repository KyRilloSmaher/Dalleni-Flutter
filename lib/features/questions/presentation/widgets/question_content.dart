import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class QuestionContent extends StatelessWidget {
  const QuestionContent({
    super.key,
    required this.title,
    this.content,
    required this.isDetailsView,
  });

  final String title;
  final String? content;
  final bool isDetailsView;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;
    final hasContent = content != null && content!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        if (hasContent) ...[
          const SizedBox(height: 10),
          Text(
            content!,
            maxLines: isDetailsView ? null : 5,
            overflow: isDetailsView ? null : TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              height: 1.55,
            ),
          ),
        ],
      ],
    );
  }
}
