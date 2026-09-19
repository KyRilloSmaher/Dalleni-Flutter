import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    required this.suggestion,
    required this.colors,
    required this.textTheme,
    required this.onTap,
  });

  final String suggestion;
  final DalleniColors colors;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}