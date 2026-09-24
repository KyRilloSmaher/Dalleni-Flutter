import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class QuestionHeader extends StatelessWidget {
  const QuestionHeader({
    super.key,
    required this.authorName,
    this.authorProfileImageUrl,
    required this.createdAtLabel,
    this.onMorePressed,
  });

  final String authorName;
  final String? authorProfileImageUrl;
  final String createdAtLabel;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: colors.surfaceContainerHighest,
            backgroundImage: authorProfileImageUrl != null
                ? NetworkImage(authorProfileImageUrl!)
                : null,
            child: authorProfileImageUrl == null
                ? Icon(
                    Icons.person_outline_rounded,
                    color: colors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      createdAtLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.public,
                      size: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMorePressed ?? () {},
            icon: Icon(
              Icons.more_horiz_rounded,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
