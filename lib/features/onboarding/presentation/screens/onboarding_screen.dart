import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/app_entry_controller.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/widgets/language_theme_bar.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(onboardingControllerProvider);
    final colors = context.dalleniColors;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.background,
              colors.surfaceContainerLow,
              colors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: stateAsync.when(
            loading: () => const AppLoadingState(),
            error: (_, __) => AppErrorState(
              message: context.l10n.translate('genericError'),
              onRetry: () => ref.invalidate(onboardingControllerProvider),
            ),
            data: (state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// ================= TOP ACTIONS =================
                        Row(
                          children: [
                            const Expanded(child: LanguageThemeBar()),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () async {
                                await ref
                                    .read(appEntryControllerProvider.notifier)
                                    .completeOnboarding();
                              },
                              child: Text(context.l10n.translate('skip')),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// ================= MAIN CARD =================
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              /// ================= PAGE CONTENT =================
                              SizedBox(
                                height: 420,
                                child: PageView.builder(
                                  controller: _controller,
                                  onPageChanged: (i) {
                                    ref
                                        .read(
                                          onboardingControllerProvider.notifier,
                                        )
                                        .updateCurrentPage(i);
                                  },
                                  itemCount: state.pages.length,
                                  itemBuilder: (context, index) {
                                    return OnboardingPageContent(
                                      page: state.pages[index],
                                      currentPage: state.currentPage,
                                      totalPages: state.pages.length,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              /// ================= DOTS =================
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(state.pages.length, (
                                  i,
                                ) {
                                  final active = i == state.currentPage;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: active ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? colors.primary
                                          : colors.onSurfaceVariant.withOpacity(
                                              0.4,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// ================= ACTION BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (state.isLastPage) {
                                ref
                                    .read(appEntryControllerProvider.notifier)
                                    .completeOnboarding();
                              } else {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              state.isLastPage
                                  ? context.l10n.translate('getStarted')
                                  : context.l10n.translate('next'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
