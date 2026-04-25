import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/question_entity.dart';
import '../screens/question_details_screen.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.isDetailsView = false,
    this.isSaved = false,
    this.onUpvote,
    this.onDownvote,
    this.onSaveToggle,
    this.onCategoryTap,
    this.onTagTap,
  });

  final Question question;
  final bool isDetailsView;
  final bool isSaved;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onSaveToggle;
  final void Function(String categoryId, String categoryName)? onCategoryTap;
  final void Function(QuestionTag tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;
    final createdAtLabel = DateFormat.yMMMd().add_jm().format(
      question.createdAt.toLocal(),
    );

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isDetailsView
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuestionDetailsScreen(question: question),
                  ),
                );
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: question.authorProfileImageUrl != null
                      ? NetworkImage(question.authorProfileImageUrl!)
                      : null,
                  child: question.authorProfileImageUrl == null
                      ? Icon(
                          Icons.person_outline_rounded,
                          color: colors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        question.authorName,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        createdAtLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatPill(
                  icon: Icons.visibility_outlined,
                  label: '${question.views}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.title,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (question.content != null &&
                question.content!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                question.content!,
                maxLines: isDetailsView ? null : 3,
                overflow: isDetailsView ? null : TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            if (question.categoryId != null &&
                question.categoryName != null) ...<Widget>[
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ActionChip(
                  backgroundColor: colors.surfaceContainerHigh,
                  side: BorderSide(color: colors.outlineVariant),
                  label: Text(question.categoryName!),
                  labelStyle: textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  onPressed: onCategoryTap == null
                      ? null
                      : () => onCategoryTap!(
                          question.categoryId!,
                          question.categoryName!,
                        ),
                ),
              ),
            ],
            if (question.tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: question.tags
                    .map(
                      (tag) => ActionChip(
                        backgroundColor: colors.surfaceContainerHigh,
                        side: BorderSide(color: colors.outlineVariant),
                        label: Text(tag.name),
                        labelStyle: textTheme.labelMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: onTagTap == null
                            ? null
                            : () => onTagTap!(tag),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _ActionButton(
                  icon: Icons.arrow_upward_rounded,
                  label: '${question.upVotes}',
                  onPressed: onUpvote,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: '${question.downVotes}',
                  onPressed: onDownvote,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${question.answersCount}',
                  onPressed: isDetailsView
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuestionDetailsScreen(question: question),
                            ),
                          );
                        },
                ),
                const Spacer(),
                IconButton(
                  onPressed: onSaveToggle,
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colors.surfaceContainerHigh,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
