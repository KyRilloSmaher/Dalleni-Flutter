import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import '../screens/question_details_screen.dart';

class FbPostCard extends StatelessWidget {
  const FbPostCard({
    super.key,
    required this.question,
    this.isDetailsView = false,
    this.isSaved = false,
    this.onUpvote,
    this.onDownvote,
    this.onSaveToggle,
    required this.onCategoryTap,
    this.onTagTap,
  });

  final Question question;
  final bool isDetailsView;
  final bool isSaved;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onSaveToggle;
  final VoidCallback onCategoryTap;
  final void Function(QuestionTag tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    final createdAtLabel = DateFormat.yMMMd().add_jm().format(
      question.createdAt.toLocal(),
    );

    print('Gategory id  ${question.categoryId}');
    print('Gategory name  ${question.categoryName}');

    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Section: User info & Options
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: question.authorProfileImageUrl != null
                      ? NetworkImage(question.authorProfileImageUrl!)
                      : null,
                  child: question.authorProfileImageUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          color: colors.primary,
                          size: 22,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        question.authorName,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          Text(
                            createdAtLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          if (question.categoryName != null) ...<Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                '•',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: onCategoryTap,
                              child: Text(
                                question.categoryName!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (!isDetailsView) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              QuestionDetailsScreen(question: question),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Main Clickable Post Content Area
          InkWell(
            onTap: isDetailsView
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            QuestionDetailsScreen(question: question),
                      ),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    question.title,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  if (question.content != null &&
                      question.content!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      question.content!,
                      maxLines: isDetailsView ? null : 4,
                      overflow: isDetailsView ? null : TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                  if (question.tags.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: question.tags
                          .map(
                            (tag) => InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: onTagTap == null
                                  ? null
                                  : () => onTagTap!(tag),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#${tag.name}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Engagement Stats Summary Row (Facebook style Likes / Comments / Views)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: <Widget>[
                Icon(Icons.thumb_up_rounded, size: 14, color: colors.primary),
                const SizedBox(width: 4),
                Text(
                  '${question.upVotes}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${question.answersCount} answers  •  ${question.views} views',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            height: 1,
            thickness: 0.8,
          ),

          // Facebook Social Action Row (Upvote, Downvote, Answer, Save)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _FbActionButton(
                    icon: Icons.thumb_up_alt_outlined,
                    activeIcon: Icons.thumb_up_alt_rounded,
                    label: 'Upvote',
                    isActive: false,
                    activeColor: colors.primary,
                    onPressed: onUpvote,
                  ),
                ),
                Expanded(
                  child: _FbActionButton(
                    icon: Icons.thumb_down_alt_outlined,
                    label: 'Downvote',
                    isActive: false,
                    activeColor: colors.error,
                    onPressed: onDownvote,
                  ),
                ),
                Expanded(
                  child: _FbActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Answer',
                    isActive: false,
                    activeColor: colors.primary,
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
                ),
                Expanded(
                  child: _FbActionButton(
                    icon: isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: isSaved ? 'Saved' : 'Save',
                    isActive: isSaved,
                    activeColor: colors.primary,
                    onPressed: onSaveToggle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FbActionButton extends StatelessWidget {
  const _FbActionButton({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.onPressed,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    final iconColor = isActive ? activeColor : colors.onSurfaceVariant;
    final textColor = isActive ? activeColor : colors.onSurfaceVariant;
    final effectiveIcon = (isActive && activeIcon != null) ? activeIcon! : icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(effectiveIcon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
