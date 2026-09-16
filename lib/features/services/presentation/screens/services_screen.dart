import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/services_controller.dart';
import '../widgets/services_categories_grid.dart';
import '../widgets/services_empty_state.dart';
import '../widgets/services_error_state.dart';
import '../widgets/services_guidance_banner.dart';
import '../widgets/services_hero_section.dart';
import '../widgets/services_list.dart';
import '../widgets/services_skeleton_loader.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesControllerProvider);
    final colors = context.dalleniColors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(title: context.l10n.translate('navServices')),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(servicesControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const ServicesHeroSection(),
              if (state.isLoading)
                const ServicesSkeletonLoader()
              else if (state.errorMessage != null)
                ServicesErrorState(
                  errorMessage: state.errorMessage!,
                  onRetry: () =>
                      ref.read(servicesControllerProvider.notifier).refresh(),
                )
              else if (state.services.isEmpty && state.categories.isEmpty)
                const ServicesEmptyState()
              else ...[
                if (!state.isSearching) const ServicesGuidanceBanner(),
                if (state.services.isNotEmpty)
                  ServicesList(services: state.services)
                else
                  ServicesCategoriesGrid(categories: state.categories),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ),
      ),
    );
  }
}
