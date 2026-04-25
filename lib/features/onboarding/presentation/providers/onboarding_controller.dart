// =====================================
// FILE 1: onboarding_controller.dart
// =====================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_service.dart';

class OnboardingPageItem {
  const OnboardingPageItem({
    required this.imageLight,
    required this.imageDark,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String imageLight;
  final String imageDark;
  final String titleKey;
  final String subtitleKey;
}

class OnboardingState {
  const OnboardingState({
    required this.pages,
    required this.currentPage,
    required this.selectedLanguageCode,
  });

  final List<OnboardingPageItem> pages;
  final int currentPage;
  final String selectedLanguageCode;

  bool get isLastPage => currentPage == pages.length - 1;

  OnboardingState copyWith({
    List<OnboardingPageItem>? pages,
    int? currentPage,
    String? selectedLanguageCode,
  }) {
    return OnboardingState(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
    );
  }
}

class OnboardingController extends AsyncNotifier<OnboardingState> {
  @override
  Future<OnboardingState> build() async {
    final locale = ref.read(localizationControllerProvider);

    return OnboardingState(
      pages: const [
        OnboardingPageItem(
          imageLight: 'assets/images/onboarding1_light.svg',
          imageDark: 'assets/images/onboarding1_dark.svg',
          titleKey: 'onboarding1Title',
          subtitleKey: 'onboarding1Subtitle',
        ),
        OnboardingPageItem(
          imageLight: 'assets/images/onboarding2_light.svg',
          imageDark: 'assets/images/onboarding2_dark.svg',
          titleKey: 'onboarding2Title',
          subtitleKey: 'onboarding2Subtitle',
        ),
      ],
      currentPage: 0,
      selectedLanguageCode: locale.languageCode,
    );
  }

  void updateCurrentPage(int index) {
    final current = state.valueOrNull;
    if (current == null || index == current.currentPage) return;
    state = AsyncData(current.copyWith(currentPage: index));
  }

  Future<void> selectLanguage(String code) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(localizationControllerProvider.notifier)
        .setLocale(Locale(code));

    state = AsyncData(current.copyWith(selectedLanguageCode: code));
  }

  Future<void> completeOnboarding() async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(localizationControllerProvider.notifier)
        .setLocale(Locale(current.selectedLanguageCode));
  }
}

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
