import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_service.dart';
import '../../../../core/theme/theme_provider.dart';

class LoginScreenActions extends ConsumerWidget {
  const LoginScreenActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localizationControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        PopupMenuButton<Locale>(
          initialValue: locale,
          onSelected: (selectedLocale) {
            ref
                .read(localizationControllerProvider.notifier)
                .setLocale(selectedLocale);
          },
          itemBuilder: (context) => <PopupMenuEntry<Locale>>[
            PopupMenuItem<Locale>(
              value: const Locale('en'),
              child: Text(context.l10n.translate('languageEnglish')),
            ),
            PopupMenuItem<Locale>(
              value: const Locale('ar'),
              child: Text(context.l10n.translate('languageArabic')),
            ),
          ],
          child: Chip(label: Text(context.l10n.translate('changeLanguage'))),
        ),
        PopupMenuButton<ThemeMode>(
          initialValue: themeMode,
          onSelected: (selectedThemeMode) {
            ref
                .read(themeControllerProvider.notifier)
                .setThemeMode(selectedThemeMode);
          },
          itemBuilder: (context) => <PopupMenuEntry<ThemeMode>>[
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Text(context.l10n.translate('themeSystem')),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Text(context.l10n.translate('themeLight')),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Text(context.l10n.translate('themeDark')),
            ),
          ],
          child: Chip(label: Text(context.l10n.translate('changeTheme'))),
        ),
      ],
    );
  }
}
