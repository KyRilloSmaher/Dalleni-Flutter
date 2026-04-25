// =====================================
// FILE 2: onboarding_page_content.dart
// =====================================

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../providers/onboarding_controller.dart';

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.page,
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  final OnboardingPageItem page;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imagePath = isDark ? page.imageDark : page.imageLight;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Image.asset(
                imagePath,
                key: ValueKey(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Text(
          l10n.translate(page.titleKey),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.translate(page.subtitleKey),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalPages, (i) {
            final active = i == currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? colors.primary
                    : colors.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }
}
