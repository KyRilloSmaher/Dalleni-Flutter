import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class ServicesEmptyState extends StatelessWidget {
  const ServicesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

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
}
