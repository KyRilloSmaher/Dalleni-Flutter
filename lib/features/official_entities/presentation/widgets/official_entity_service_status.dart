import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class OfficialEntityServiceStatus extends StatelessWidget {
  const OfficialEntityServiceStatus({super.key, required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final statusColor = isAvailable
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
    final bgColor = isAvailable
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    final textKey = isAvailable ? 'serviceAvailable' : 'serviceUnavailable';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.translate(textKey),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
