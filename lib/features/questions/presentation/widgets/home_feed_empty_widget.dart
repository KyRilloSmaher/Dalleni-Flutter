import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';

class HomeFeedEmptyWidget extends StatelessWidget {
  const HomeFeedEmptyWidget({
    super.key,
    required this.selectedCategory,
    required this.onClearFilter,
  });

  final QuestionCategory? selectedCategory;
  final VoidCallback onClearFilter;

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
                Icons.dynamic_feed_rounded,
                size: 64,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.translate('homeEmptyTitle'),
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.translate('homeEmptySubtitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (selectedCategory != null) ...<Widget>[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: onClearFilter,
                  icon: const Icon(
                    Icons.filter_alt_off_rounded,
                  ),
                  label: const Text('Clear Filter'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
