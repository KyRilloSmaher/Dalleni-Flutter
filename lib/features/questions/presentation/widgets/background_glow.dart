import 'package:dalleni/core/theme/dalleni_theme.dart';
import 'package:flutter/material.dart';

class BackgroundGlow extends StatelessWidget {
  const BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Positioned(
      top: -100,
      left: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary.withOpacity(0.15),
        ),
      ),
    );
  }
}