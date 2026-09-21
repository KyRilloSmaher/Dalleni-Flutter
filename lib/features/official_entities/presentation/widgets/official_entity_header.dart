import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/official_entity.dart';
import 'official_entity_logo.dart';
import 'official_entity_verification_badge.dart';

class OfficialEntityHeader extends StatelessWidget {
  const OfficialEntityHeader({super.key, required this.entity});

  final OfficialEntity entity;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        OfficialEntityLogo(
          logoUrl: entity.logoUrl,
          name: entity.name,
          size: 88,
          borderRadius: 24,
        ),
        const SizedBox(height: 16),
        Text(
          entity.name ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        if (entity.isVerified) ...<Widget>[
          const SizedBox(height: 8),
          OfficialEntityVerificationBadge(
            isVerified: entity.isVerified,
            showText: true,
            size: 16,
          ),
        ],
      ],
    );
  }
}
