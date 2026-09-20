import 'package:dalleni/features/profile/presentation/screens/question_user_screen.dart';
import 'package:dalleni/features/profile/presentation/widgets/activity_tile.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_profile.dart';

class ProfileActivity extends StatelessWidget {
  const ProfileActivity({
    super.key,
    required this.profile,
    required this.onSavedQuestionsTap,
  });

  final UserProfile profile;
  final VoidCallback onSavedQuestionsTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timeline_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'My Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colors.outline.withValues(alpha: 0.12)),

          ActivityTile(
            icon: Icons.bookmark_rounded,
            iconColor: colors.primary,
            title: 'Saved Questions',
            subtitle: 'Questions you saved for later',
            onTap: onSavedQuestionsTap,
          ),

          ActivityTile(
            icon: Icons.help_outline_rounded,
            iconColor: colors.secondary,
            title: 'My Questions',
            subtitle: '${profile.questionsCount} questions',
            onTap: () {
              Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuestionsUserScreen(),
                        ),
                      );
            },
          ),
        ],
      ),
    );
  }
}
