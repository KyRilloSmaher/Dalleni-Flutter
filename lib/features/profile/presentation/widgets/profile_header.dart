import 'package:dalleni/features/profile/presentation/widgets/cover_section.dart';
import 'package:dalleni/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditProfile,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    final hasImage =
        profile.profileImageUrl != null &&
        profile.profileImageUrl!.isNotEmpty;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          CoverSection(colors: colors),

          Transform.translate(
            offset: const Offset(0, -42),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ProfileAvatar(
                    imageUrl: profile.profileImageUrl,
                    hasImage: hasImage,
                    colors: colors,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          profile.fullName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                        ),
                      ),
                      if (profile.reputation > 500) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          color: colors.primary,
                          size: 21,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '@${profile.userName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: 180,
                    child: AppButton(
                      label: 'Edit Profile',
                      isOutlined: true,
                      onPressed: onEditProfile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



