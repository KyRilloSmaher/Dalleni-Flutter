import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class Footer extends StatelessWidget {
  const Footer({
    super.key,
    required this.colors,
    required this.savedAt,
    required this.isNeed,
  });

  final dynamic colors;
  final DateTime savedAt;
  final bool isNeed;

  @override
  Widget build(BuildContext context) {
    final formattedDate = intl.DateFormat('MMM d, yyyy').format(savedAt);

    return Row(
      children: [
        if (isNeed) ...[
          Icon(
            Icons.bookmark_border_rounded,
            size: 17,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          isNeed ? 'Saved $formattedDate' : formattedDate,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
