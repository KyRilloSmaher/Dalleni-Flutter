import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ActivityHeader extends StatelessWidget {
  const ActivityHeader({
    required this.question,
    required this.colors,
    required this.savedAt,
    this.onRemove,
  });

  final Question question;
  final dynamic colors;
  final DateTime savedAt;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          question: question,
          colors: colors,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
               question.authorName ,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                 intl.DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(savedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: 'Remove from saved',
          onPressed: onRemove,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.bookmark_rounded,
            color: colors.primary,
          ),
        ),
      ],
    );
  }

 

}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.question,
    required this.colors,
  });

  final Question question;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: colors.primary.withValues(alpha: 0.10),
      child: Icon(
        Icons.person_rounded,
        color: colors.primary,
        size: 22,
      ),
    );
  }
}