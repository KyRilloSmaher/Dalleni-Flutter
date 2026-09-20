import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/user_profile.dart';
import 'profile_stat_item.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatItem(
              value: profile.reputation.toString(),
              label: 'Reputation',
              icon: Icons.star_rounded,
            ),
          ),
          _Divider(color: colors.outline),
          Expanded(
            child: ProfileStatItem(
              value: profile.questionsCount.toString(),
              label: 'Questions',
              icon: Icons.help_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 1,
      color: color.withValues(alpha: 0.15),
    );
  }
}
