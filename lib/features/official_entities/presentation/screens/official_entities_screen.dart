import 'package:dalleni/features/official_entities/presentation/widgets/officail_entites_empty.dart';
import 'package:dalleni/features/official_entities/presentation/widgets/officail_entites_error.dart';
import 'package:dalleni/features/official_entities/presentation/widgets/officail_entites_header.dart';
import 'package:dalleni/features/official_entities/presentation/widgets/officail_entites_succes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/official_entities_controller.dart';
import '../widgets/official_entity_skeleton.dart';

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
                  const OfficialEntitiesHeader(),

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
                    OfficialEntitiesError(
                      message: state.errorMessage ?? '',
                      onRetry: controller.refresh,
                    )
                  // Empty State
                  else if (state.showEmptyState)
                    OfficialEntitiesEmpty(
                      onRetry: controller.refresh,
                    )
                  // Entities List (ListView.builder delegation via SliverList)
                  else
                    OfficialEntitiesSuccess(
                      entities: state.entities,
                      isLoadingMore: state.isLoadingMore,
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

