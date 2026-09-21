import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/official_entity.dart';

class OfficialEntityInfoCard extends StatelessWidget {
  const OfficialEntityInfoCard({super.key, required this.entity});

  final OfficialEntity entity;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final hasDescription =
        entity.description != null && entity.description!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasDescription) ...<Widget>[
            Text(
              entity.description!.trim(),
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: colors.outlineVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
          ],
          Row(
            children: <Widget>[
              Icon(Icons.grid_view_rounded, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                '${context.l10n.translate('officialEntityServicesTitle')}: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Text(
                '${entity.servicesCount}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
