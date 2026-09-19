import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dalleni_theme.dart';
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

  final VoidCallback? onCategoryTap;

  final void Function(QuestionTag tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final textTheme = Theme.of(context).textTheme;

    final createdAtLabel = DateFormat.yMMMd().add_jm().format(
      question.createdAt.toLocal(),
    );

    return Container(
      width: double.infinity,
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // POST HEADER
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
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

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.authorName,
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // QUESTION CONTENT
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.title,
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),

                  if (question.content != null &&
                      question.content!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      question.content!,
                      maxLines: isDetailsView ? null : 5,
                      overflow: isDetailsView ? null : TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        height: 1.55,
                      ),
                    ),
                  ],

                  // =========================
                  // CATEGORY
                  // =========================
                  if (question.categoryId != null &&
                      question.categoryName != null) ...[
                    const SizedBox(height: 14),
                    ActionChip(
                      backgroundColor: colors.surfaceContainerHigh,
                      side: BorderSide.none,
                      label: Text(question.categoryName!),
                      labelStyle: textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      onPressed: onCategoryTap 
                    ),
                  ],

                  // =========================
                  // TAGS
                  // =========================
                  if (question.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: question.tags
                          .map(
                            (tag) => ActionChip(
                              backgroundColor: colors.surfaceContainerHigh,
                              side: BorderSide.none,
                              label: Text('#${tag.name}'),
                              labelStyle: textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // =========================
          // STATS
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (question.upVotes > 0)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: colors.primary,
                        child: const Icon(
                          Icons.thumb_up,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${question.upVotes}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                const Spacer(),

                Text(
                  '${question.answersCount} answers',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  '${question.views} views',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Divider(height: 1, color: colors.outlineVariant),

          // Facebook-like separator between posts.
          Container(height: 8, color: colors.surfaceContainerLowest),
        ],
      ),
    );
  }
}
