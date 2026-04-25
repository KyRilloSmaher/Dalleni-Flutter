import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/dalleni_theme.dart';
import '../theme/theme_provider.dart';

class CommonGlassAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// Defines a unified strict RTL layout behavior
  const CommonGlassAppBar({
    super.key,
    required this.title,
    this.trailingActions,
    this.scaffoldKey,
  });

  final String title;
  final List<Widget>? trailingActions;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.dalleniColors;
    final themeMode = ref.watch(themeControllerProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final logoAsset = isDark
        ? 'assets/images/dalleni_logo_dark.png'
        : 'assets/images/dalleni_logo_light.png';

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AppBar(
          backgroundColor: colors.surfaceContainerLow.withOpacity(0.7),
          elevation: 0,
          // Natively RTL automatically puts 'leading' firmly to the visual RIGHT side of the application.
          // Tapping this explicitly resolves the outer MainLayout Screen context to pop open the Drawer!
          leading: IconButton(
            icon: Icon(Icons.sort_rounded, color: colors.onSurface),
            onPressed: () {
              // Safely open drawer using global key if passed, else fallback
              if (scaffoldKey != null) {
                scaffoldKey!.currentState?.openDrawer();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          ),
          centerTitle: true,
          title: Text(
            title.isNotEmpty ? title : "Dalleni", // Fallback text safely
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1.0,
              color: colors.onSurface,
              fontFamily: 'Manrope', // Premium editorial constraint
            ),
          ),
          // Actions naturally fall to the visual LEFT side of an Arabic application.
          actions: [
            if (trailingActions != null) ...trailingActions!,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                logoAsset,
                height: 32,
                width: 32,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.hive_rounded, // fallback if asset not physically loaded
                  color: colors.primary,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
