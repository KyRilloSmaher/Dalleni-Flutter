import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/official_entity.dart';
import 'official_entity_logo.dart';
import 'official_entity_verification_badge.dart';

class OfficialEntityCard extends StatelessWidget {
  const OfficialEntityCard({
    super.key,
    required this.entity,
    required this.onTap,
  });

  final OfficialEntity entity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: colors.primary.withValues(alpha: 0.04),
          splashColor: colors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OfficialEntityLogo(
                  logoUrl: entity.logoUrl,
                  name: entity.name,
                  size: 56,
                  borderRadius: 16,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              entity.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (entity.isVerified) ...<Widget>[
                            const SizedBox(width: 6),
                            OfficialEntityVerificationBadge(
                              isVerified: entity.isVerified,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      if (entity.description != null &&
                          entity.description!.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          entity.description!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.miscellaneous_services_rounded,
                                  size: 14,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${entity.servicesCount} ${context.l10n.translate('officialEntityServicesCount')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            isRtl
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
