import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';

class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({
    required this.imagePath,
    required this.onPickImage,
    super.key,
  });

  final String? imagePath;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primaryContainer,
            backgroundImage: hasImage ? FileImage(File(imagePath!)) : null,
            child: hasImage
                ? null
                : Icon(
                    Icons.person_outline_rounded,
                    color: colors.onPrimaryContainer,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.translate('profileImageLabel'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.translate('profileImageHint'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPickImage,
            child: Text(
              context.l10n.translate(
                hasImage ? 'changeImageButton' : 'chooseImageButton',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
