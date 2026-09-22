import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../official_entities/presentation/screens/official_entities_screen.dart';
import '../providers/services_controller.dart';

class ServicesHeroSection extends ConsumerWidget {
  const ServicesHeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.dalleniColors;
    final state = ref.watch(servicesControllerProvider);
    const title = "Explore Official Services";
    const searchPlaceholder = "البحث عن خدمة (رخصة، بطاقة، مرور...)";

    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverToBoxAdapter(
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.onSurfaceVariant.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          ref
                              .read(servicesControllerProvider.notifier)
                              .searchServices(value);
                        },
                        decoration: InputDecoration(
                          hintText: searchPlaceholder,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (state.searchQuery.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.close, color: colors.onSurfaceVariant),
                        onPressed: () {
                          ref
                              .read(servicesControllerProvider.notifier)
                              .clearSearch();
                        },
                        tooltip: 'Clear',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OfficialEntitiesScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "الجهات الرسمية",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            Text(
                              "استكشف الوزارات والمؤسسات الرسمية والخدمات التابعة لها",
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colors.primary,
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
