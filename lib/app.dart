import 'package:dalleni/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app/app_entry_controller.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_service.dart';
import 'core/theme/dalleni_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/screens/auth_flow_screen.dart';
import 'features/main/presentation/screens/main_layout_screen.dart';

class DalleniApp extends ConsumerWidget {
  const DalleniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localizationControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final appState = ref.watch(appEntryControllerProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.translate('appTitle'),
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final direction = AppLocalizations.of(context).textDirection;

        return Directionality(
          textDirection: direction,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: DalleniTheme.lightTheme(locale),
      darkTheme: DalleniTheme.darkTheme(locale),
      themeMode: themeMode,

      home: switch (appState) {
        AppStartState.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),

        AppStartState.onboarding => const OnboardingScreen(),

        AppStartState.auth => const AuthFlowScreen(),

        AppStartState.main => const MainLayoutScreen(),
      },
    );
  }
}
