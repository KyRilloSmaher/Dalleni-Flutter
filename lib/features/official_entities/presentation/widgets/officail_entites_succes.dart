import 'package:dalleni/features/official_entities/presentation/screens/official_entity_details_screen.dart' show OfficialEntityDetailsScreen;
import 'package:dalleni/features/official_entities/presentation/widgets/official_entity_card.dart';
import 'package:flutter/material.dart';

class OfficialEntitiesSuccess extends StatelessWidget {
  const OfficialEntitiesSuccess({
    required this.entities,
    required this.isLoadingMore,
    super.key,
  });

  final List<dynamic> entities;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= entities.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final entity = entities[index];

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
        childCount: entities.length + (isLoadingMore ? 1 : 0),
      ),
    );
  }
}