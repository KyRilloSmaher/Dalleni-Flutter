import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class OfficialEntitiesEmpty extends StatelessWidget {
  const OfficialEntitiesEmpty({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.account_balance_outlined,
                size: 64,
                color: colors.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.translate('officialEntityEmptyTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.translate('officialEntityEmptySubtitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  context.l10n.translate('retryButton'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}