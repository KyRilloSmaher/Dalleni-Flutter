import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';

class LocalizationController extends Notifier<Locale> {
  @override
  Locale build() {
    final savedLanguage =
        ref.read(localStorageServiceProvider).getLanguage() ?? 'en';
    return Locale(savedLanguage);
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) {
      return;
    }

    state = locale;
    await ref
        .read(localStorageServiceProvider)
        .saveLanguage(locale.languageCode);
  }
}

final localizationControllerProvider =
    NotifierProvider<LocalizationController, Locale>(
      LocalizationController.new,
    );
