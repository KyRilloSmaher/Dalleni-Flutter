import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class ServicesSkeletonLoader extends StatelessWidget {
  const ServicesSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

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
}
