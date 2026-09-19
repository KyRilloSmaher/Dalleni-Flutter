import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';

class AskHeroSection extends StatelessWidget {
  const AskHeroSection({
    super.key,
    required this.colors,
    required this.textTheme,
    required this.l10n,
  });

  final DalleniColors colors;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            l10n.translate('askHeroBadge') ?? 'ASSISTANT',
            style: textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          l10n.translate('askHeroTitle') ??
              'Ask about any service...',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          l10n.translate('askHeroSubtitle') ??
              'We are here to simplify procedures and guide you step by step.',
          style: textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant.withOpacity(0.8),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}