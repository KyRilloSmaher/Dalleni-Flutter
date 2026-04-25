import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show Intl;

class AppLocalizations {
  AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, String> _translations;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations is not configured.');
    return localizations!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final normalizedLocale =
        supportedLocales.any(
          (supportedLocale) =>
              supportedLocale.languageCode == locale.languageCode,
        )
        ? locale
        : const Locale('en');
    final jsonString = await rootBundle.loadString(
      'assets/lang/${normalizedLocale.languageCode}.json',
    );
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    Intl.defaultLocale = normalizedLocale.languageCode;

    return AppLocalizations(
      normalizedLocale,
      jsonMap.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  String translate(String key) => _translations[key] ?? key;

  bool get isArabic => locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
