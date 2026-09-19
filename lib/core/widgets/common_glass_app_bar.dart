import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/dalleni_theme.dart';

class CommonGlassAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CommonGlassAppBar({
    super.key,
    required this.title,
    this.trailingActions,
    this.scaffoldKey,
  });

  final String title;
  final List<Widget>? trailingActions;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  static const double _height = 60;
  static const double _radius = 30;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  void _openDrawer(BuildContext context) {
    if (scaffoldKey != null) {
      scaffoldKey!.currentState?.openDrawer();
      return;
    }

    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.dalleniColors;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(_radius),
        bottomRight: Radius.circular(_radius),
      ),
      child: AppBar(
        toolbarHeight: _height,
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        leadingWidth: 52,

        leading: IconButton(
          onPressed: () => _openDrawer(context),
          icon: Icon(Icons.menu_rounded, color: colors.onSurface, size: 25),
          tooltip: 'Menu',
        ),

        titleSpacing: 0,

        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            fontFamily: 'Manrope',
          ),
        ),

        actions: [
          if (trailingActions != null) ...trailingActions!,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
