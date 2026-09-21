import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';

class OfficialEntityVerificationBadge extends StatelessWidget {
  const OfficialEntityVerificationBadge({
    super.key,
    required this.isVerified,
    this.size = 18.0,
    this.showText = false,
  });

  final bool isVerified;
  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    final colors = context.dalleniColors;

    if (!showText) {
      return Icon(Icons.verified_rounded, size: size, color: colors.tertiary);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.verified_rounded, size: size, color: colors.tertiary),
          const SizedBox(width: 4),
          Text(
            context.l10n.translate('officialEntityVerified'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
