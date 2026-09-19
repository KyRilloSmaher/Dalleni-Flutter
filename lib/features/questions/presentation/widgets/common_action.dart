
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class CommentAction extends StatelessWidget {
  const CommentAction({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActive
              ? activeColor
              : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
