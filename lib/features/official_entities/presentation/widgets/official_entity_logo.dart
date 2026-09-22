import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class OfficialEntityLogo extends StatelessWidget {
  const OfficialEntityLogo({
    super.key,
    this.logoUrl,
    this.name,
    this.size = 52.0,
    this.borderRadius = 16.0,
  });

  final String? logoUrl;
  final String? name;
  final double size;
  final double borderRadius;

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '🏛️';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final hasLogo = logoUrl != null && logoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: hasLogo
            ? Image.network(
                logoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(colors),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary,
                        ),
                      ),
                    ),
                  );
                },
              )
            : _buildFallback(colors),
      ),
    );
  }

  Widget _buildFallback(DalleniColors colors) {
    final initials = _getInitials(name);
    return Center(
      child: initials == '🏛️'
          ? Icon(
              Icons.account_balance_rounded,
              size: size * 0.52,
              color: colors.primary,
            )
          : Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
    );
  }
}
