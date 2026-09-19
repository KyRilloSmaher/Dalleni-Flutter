import 'package:dalleni/features/questions/presentation/widgets/suggestion_tile.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';

class SmartSuggestions extends StatelessWidget {
  const SmartSuggestions({
    super.key,
    required this.suggestions,
    required this.colors,
    required this.textTheme,
    required this.l10n,
    required this.onSuggestionSelected,
  });

  final List<String> suggestions;
  final DalleniColors colors;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final ValueChanged<String> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 18,
              color: colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.translate('askSmartSuggestions') ??
                  'Smart Suggestions',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...suggestions.map(
          (suggestion) => SuggestionTile(
            suggestion: suggestion,
            colors: colors,
            textTheme: textTheme,
            onTap: () => onSuggestionSelected(suggestion),
          ),
        ),
      ],
    );
  }
}

