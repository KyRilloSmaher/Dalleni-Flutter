import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class OfficialEntitiesHeader extends StatelessWidget {
  const OfficialEntitiesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return SliverToBoxAdapter(
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.account_balance_rounded,
                color: colors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.translate('officialEntitiesTitle'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.translate('officialEntitiesSubtitle'),
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}