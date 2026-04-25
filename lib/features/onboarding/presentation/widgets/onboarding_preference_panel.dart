import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_card.dart';

class OnboardingPreferencePanel extends StatelessWidget {
  const OnboardingPreferencePanel({
    required this.selectedLanguageCode,
    required this.themeMode,
    required this.onLanguageSelected,
    required this.onThemeChanged,
    super.key,
  });

  final String selectedLanguageCode;
  final ThemeMode themeMode;
  final ValueChanged<String> onLanguageSelected;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          /// ================= LANGUAGE =================
          _SectionTitle(title: l10n.translate('onboardingLanguageTitle')),
          const SizedBox(height: 12),

          _LanguageSelector(
            selectedLanguageCode: selectedLanguageCode,
            onLanguageSelected: onLanguageSelected,
          ),

          const SizedBox(height: 24),

          /// ================= THEME =================
          _SectionTitle(title: l10n.translate('onboardingThemeTitle')),
          const SizedBox(height: 12),

          _ThemeSelector(themeMode: themeMode, onThemeChanged: onThemeChanged),
        ],
      ),
    );
  }
}

/// ================= SECTION TITLE =================
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// ================= LANGUAGE SELECTOR =================
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedLanguageCode,
    required this.onLanguageSelected,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppLocalizations.supportedLocales.map((locale) {
        final code = locale.languageCode;

        return _PreferenceChip<String>(
          label: _labelForLanguage(code, l10n),
          value: code,
          groupValue: selectedLanguageCode,
          onSelected: onLanguageSelected,
        );
      }).toList(),
    );
  }

  String _labelForLanguage(String code, AppLocalizations l10n) {
    switch (code) {
      case 'ar':
        return l10n.translate('languageArabic');
      case 'en':
        return l10n.translate('languageEnglish');
      default:
        return code.toUpperCase();
    }
  }
}

/// ================= THEME SELECTOR =================
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.themeMode, required this.onThemeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _PreferenceChip<ThemeMode>(
          label: l10n.translate('themeLight'),
          value: ThemeMode.light,
          groupValue: themeMode,
          onSelected: onThemeChanged,
        ),
        _PreferenceChip<ThemeMode>(
          label: l10n.translate('themeDark'),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onSelected: onThemeChanged,
        ),
        _PreferenceChip<ThemeMode>(
          label: l10n.translate('themeSystem'),
          value: ThemeMode.system,
          groupValue: themeMode,
          onSelected: onThemeChanged,
        ),
      ],
    );
  }
}

/// ================= GENERIC CHIP =================
class _PreferenceChip<T> extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (!isSelected) {
          onSelected(value);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
