import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../domain/entities/service_entity.dart';
import '../providers/services_controller.dart';

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
      appBar: CommonGlassAppBar(
        title: context.l10n.translate('navServices') ?? 'الخدمات',
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(servicesControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildHeroSection(context, colors),

              if (state.isLoading)
                _buildSkeletonLoader(context, colors)
              else if (state.errorMessage != null)
                _buildErrorState(context, colors, ref, state.errorMessage!)
              else ...[
                if (state.categories.isEmpty && state.quickAccessItems.isEmpty)
                  _buildEmptyState(context, colors)
                else ...[
                  _buildGuidanceBanner(context, colors),
                  _buildFeaturedCategory(
                    context,
                    colors,
                    state.featuredCategory,
                  ),
                  _buildQuickAccess(context, colors, state.quickAccessItems),
                  _buildCategories(context, colors, state.categories),
                ],
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, DalleniColors colors) {
    // Fallbacks
    final title = "Explore Official Services";
    final description = "Find and access public services بسهولة";
    final searchPlaceholder = "Search for services...";

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: searchPlaceholder,
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context, DalleniColors colors) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 100,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    DalleniColors colors,
    WidgetRef ref,
    String error,
  ) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colors.error),
              const SizedBox(height: 16),
              Text(
                "Something went wrong", // Fallback required message
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Retry',
                onPressed: () =>
                    ref.read(servicesControllerProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DalleniColors colors) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                "No services available at the moment",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceBanner(BuildContext context, DalleniColors colors) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: AppCard(
          // colors: colors.primaryContainer.withOpacity(0.4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assistant_outlined, color: colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Need help?", // Fallback title
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let our assistant guide you", // Fallback description
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCategory(
    BuildContext context,
    DalleniColors colors,
    FeaturedCategory? featured,
  ) {
    if (featured == null)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    // Fallback logic
    final title = featured.title ?? "Featured Service";
    final tags = featured.tags ?? <String>[];
    if (tags.isEmpty) {
      // Rule: hide section if tags are empty
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                // Fallback image container if imagePath is null
                child:
                    featured.imagePath != null && featured.imagePath!.isNotEmpty
                    ? Image.network(
                        featured.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderImage(colors),
                      )
                    : _buildPlaceholderImage(colors),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: tags
                  .map(
                    (t) => Chip(
                      label: Text(
                        t,
                        style: TextStyle(
                          color: colors.onSecondaryContainer,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: colors.secondaryContainer,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(DalleniColors colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: colors.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildQuickAccess(
    BuildContext context,
    DalleniColors colors,
    List<QuickAccessItem> items,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Access",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    "No recent activity", // Quick Access empty message fallback
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    // Quick Access Fallbacks
                    final title = item.title ?? "Service";
                    final subtitle = item.subtitle ?? "Details unavailable";

                    return AppCard(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.bolt,
                              color: colors.primary,
                            ), // Default Icon
                            const Spacer(),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(
    BuildContext context,
    DalleniColors colors,
    List<ServiceCategory> categories,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      sliver: categories.isEmpty
          ? SliverToBoxAdapter(
              child: Center(
                child: Text(
                  "No services available at the moment", // Fallback Empty Categories
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = categories[index];

                // Rules Fallbacks
                final name = category.name ?? "Service Category";
                final description =
                    category.description ?? "No description available";

                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: colors.surfaceContainerHighest.withOpacity(
                            0.5,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.category,
                              size: 32,
                              color: colors.onSurfaceVariant,
                            ), // Default icon
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: categories.length),
            ),
    );
  }
}
