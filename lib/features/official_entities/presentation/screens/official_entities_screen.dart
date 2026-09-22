import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/official_entities_controller.dart';
import '../widgets/official_entity_card.dart';
import '../widgets/official_entity_skeleton.dart';
import 'official_entity_details_screen.dart';

class OfficialEntitiesScreen extends ConsumerStatefulWidget {
  const OfficialEntitiesScreen({super.key});

  @override
  ConsumerState<OfficialEntitiesScreen> createState() =>
      _OfficialEntitiesScreenState();
}

class _OfficialEntitiesScreenState
    extends ConsumerState<OfficialEntitiesScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(officialEntitiesControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(officialEntitiesControllerProvider);
    final colors = context.dalleniColors;
    final controller = ref.read(officialEntitiesControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(
        title: context.l10n.translate('officialEntitiesTitle'),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: colors.primary,
              backgroundColor: colors.surface,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  // Glass AppBar offset padding
                  const SliverPadding(
                    padding: EdgeInsets.only(top: kToolbarHeight + 16),
                  ),

                  // Header Banner Section
                  SliverToBoxAdapter(
                    child: Container(
                      color: colors.surface,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: colors.primary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      context.l10n.translate(
                                        'officialEntitiesTitle',
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.l10n.translate(
                                        'officialEntitiesSubtitle',
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Feed gap
                  SliverToBoxAdapter(
                    child: Container(
                      height: 8,
                      color: colors.surfaceContainerLow,
                    ),
                  ),

                  // Initial Loading State (Skeleton)
                  if (state.isLoading && state.entities.isEmpty)
                    const SliverToBoxAdapter(
                      child: OfficialEntitySkeletonList(count: 5),
                    )
                  // Error State
                  else if (state.errorMessage != null && state.entities.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        color: colors.surface,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.error_outline_rounded,
                                size: 54,
                                color: colors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.translate('errorStateTitle'),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: controller.refresh,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(
                                  context.l10n.translate('retryButton'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Empty State
                  else if (state.showEmptyState)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                        color: colors.surface,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.account_balance_outlined,
                                size: 64,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.translate(
                                  'officialEntityEmptyTitle',
                                ),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.translate(
                                  'officialEntityEmptySubtitle',
                                ),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: controller.refresh,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(
                                  context.l10n.translate('retryButton'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  // Entities List (ListView.builder delegation via SliverList)
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.entities.length) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final entity = state.entities[index];

                          return OfficialEntityCard(
                            entity: entity,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => OfficialEntityDetailsScreen(
                                    officialEntityId: entity.id,
                                    initialEntity: entity,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount:
                            state.entities.length +
                            (state.isLoadingMore ? 1 : 0),
                      ),
                    ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
