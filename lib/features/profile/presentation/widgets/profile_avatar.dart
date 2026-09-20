
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.imageUrl,
    required this.hasImage,
    required this.colors,
  });

  final String? imageUrl;
  final bool hasImage;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: colors.surfaceContainerHighest,
        backgroundImage: hasImage
            ? NetworkImage(imageUrl!)
            : null,
        child: !hasImage
            ? Icon(
                Icons.person_rounded,
                size: 52,
                color: colors.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}