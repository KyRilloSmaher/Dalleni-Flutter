import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.titleKey,
    required this.subtitleKey,
    super.key,
  });

  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logo = isDark
        ? 'assets/images/dalleni_logo_dark.png'
        : 'assets/images/dalleni_logo_light.png';

    return Column(
      children: <Widget>[
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Image.asset(
              logo,
              semanticLabel: context.l10n.translate('logoSemanticLabel'),
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          context.l10n.translate(titleKey),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          context.l10n.translate(subtitleKey),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
