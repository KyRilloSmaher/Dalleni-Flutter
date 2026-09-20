import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class Footer extends StatelessWidget {
  const Footer({required this.colors, required this.savedAt});

  final dynamic colors;
  final DateTime savedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.bookmark_border_rounded,
          size: 17,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          'Saved ${intl.DateFormat('MMM d, yyyy').format(savedAt)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
