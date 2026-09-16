import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/service_entity.dart';

class ServicesFeaturedCategory extends StatelessWidget {
  final FeaturedCategory? featured;

  const ServicesFeaturedCategory({
    super.key,
    required this.featured,
  });

  @override
  Widget build(BuildContext context) {
    if (featured == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final colors = context.dalleniColors;
    final title = featured!.title ?? "Featured Service";
    final tags = featured!.tags ?? <String>[];
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
                child: featured!.imagePath != null &&
                        featured!.imagePath!.isNotEmpty
                    ? Image.network(
                        featured!.imagePath!,
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
}
