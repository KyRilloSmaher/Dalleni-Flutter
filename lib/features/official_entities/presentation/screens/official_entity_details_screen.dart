import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/official_entity.dart';
import '../providers/official_entity_details_controller.dart';
import '../widgets/official_entity_header.dart';
import '../widgets/official_entity_info_card.dart';
import '../widgets/official_entity_service_card.dart';
import '../widgets/official_entity_website_button.dart';

class OfficialEntityDetailsScreen extends ConsumerWidget {
  const OfficialEntityDetailsScreen({
    super.key,
    required this.officialEntityId,
    this.initialEntity,
  });

  final String officialEntityId;
  final OfficialEntity? initialEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      officialEntityDetailsControllerProvider(officialEntityId),
    );
    final controller = ref.read(
      officialEntityDetailsControllerProvider(officialEntityId).notifier,
    );
    final colors = context.dalleniColors;

    final entity = state.entity ?? initialEntity;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          entity?.name ?? context.l10n.translate('officialEntityDetailsTitle'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surfaceContainerLow,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: colors.primary,
          child: state.isLoading && entity == null
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null && entity == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: controller.refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.l10n.translate('retryButton')),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (entity != null) ...<Widget>[
                              OfficialEntityHeader(entity: entity),
                              const SizedBox(height: 20),
                              OfficialEntityInfoCard(entity: entity),
                              const SizedBox(height: 16),
                              OfficialEntityWebsiteButton(
                                websiteUrl: entity.websiteUrl,
                              ),
                              const SizedBox(height: 28),
                            ],

                            // Services Section Title
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.translate(
                                    'officialEntityServicesTitle',
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                if (state.isLoading)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Services List
                            if (!state.isLoading && state.services.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'لا توجد خدمات مسجلة لهذه الجهة حالياً.',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.services.length,
                                itemBuilder: (context, index) {
                                  final service = state.services[index];
                                  return OfficialEntityServiceCard(
                                    service: service,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
