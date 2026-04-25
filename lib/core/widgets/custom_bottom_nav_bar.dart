import 'package:flutter/material.dart';

import '../theme/dalleni_theme.dart';

class NavItem {
  const NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onItemSelected,
  });

  final int currentIndex;
  final List<NavItem> items;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(items.length, (index) {
              final isSelected = index == currentIndex;
              final isCenterItem = index == items.length ~/ 2;

              final itemWidget = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onItemSelected(index),
                child: _NavItemView(
                  item: items[index],
                  isSelected: isSelected,
                  isCenterItem: isCenterItem,
                  colors: colors,
                ),
              );

              if (isCenterItem) {
                return Transform.translate(
                  offset: const Offset(0, -20.0),
                  child: itemWidget,
                );
              }

              return itemWidget;
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemView extends StatelessWidget {
  const _NavItemView({
    required this.item,
    required this.isSelected,
    required this.isCenterItem,
    required this.colors,
  });

  final NavItem item;
  final bool isSelected;
  final bool isCenterItem;
  final DalleniColors colors;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? colors.primary : colors.onSurfaceVariant;

    // Scale and elevation for the center "Main" item
    final scale = isCenterItem ? 1.15 : (isSelected ? 1.05 : 1.0);

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCenterItem
              ? colors.primaryContainer.withOpacity(isSelected ? 0.3 : 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: colors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item.icon, color: color, size: 28),
                if (isCenterItem)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors.secondary, // Teal notification dot
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
