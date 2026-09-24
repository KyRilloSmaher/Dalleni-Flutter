import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:dalleni/features/profile/presentation/providers/profile_controller.dart';
import 'package:flutter/material.dart';

class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({
    required this.state,
    required this.onPickImage,
  });

  final ProfileState state;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final profileImageUrl = state.profile?.profileImageUrl;
    final selectedImage = state.selectedImage;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: colors.surfaceContainerHighest,
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage) as ImageProvider
                : (profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null),
            child: selectedImage == null &&
                    (profileImageUrl == null || profileImageUrl.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: colors.onSurfaceVariant,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.background,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: colors.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}