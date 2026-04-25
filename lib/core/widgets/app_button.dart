import 'package:flutter/material.dart';
import '../theme/dalleni_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.glowColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final resolvedBackgroundColor = backgroundColor ?? colors.primary;
    final resolvedForegroundColor = foregroundColor ?? colors.onPrimary;
    final resolvedBorderColor = borderColor ?? resolvedBackgroundColor;
    final resolvedGlowColor = glowColor ?? colors.primaryGlow;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: resolvedForegroundColor,
            ),
          )
        else ...[
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: resolvedBorderColor),
          backgroundColor: resolvedBackgroundColor,
          foregroundColor: resolvedForegroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null && !isLoading
            ? [
                BoxShadow(
                  color: resolvedGlowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: resolvedBackgroundColor,
              foregroundColor: resolvedForegroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return resolvedBackgroundColor.withValues(alpha: 0.5);
                }
                return resolvedBackgroundColor;
              }),
            ),
        child: child,
      ),
    );
  }
}
