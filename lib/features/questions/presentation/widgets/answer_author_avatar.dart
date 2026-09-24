import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class AnswerAuthorAvatar extends StatelessWidget {
  const AnswerAuthorAvatar({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return CircleAvatar(
      radius: 18,
      backgroundColor: colors.surfaceContainerHighest,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(
              Icons.person,
              color: colors.onSurfaceVariant,
              size: 19,
            )
          : null,
    );
  }
}
