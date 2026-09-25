import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class OfficialEntitiesError extends StatelessWidget {
  const OfficialEntitiesError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
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
                Icons.error_outline_rounded,
                size: 54,
                color: colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.translate('errorStateTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
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