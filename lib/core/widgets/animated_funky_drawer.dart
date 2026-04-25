import 'package:flutter/material.dart';
import '../../features/questions/presentation/screens/saved_questions_screen.dart';
import '../theme/dalleni_theme.dart';

class AnimatedFunkyDrawer extends StatefulWidget {
  const AnimatedFunkyDrawer({super.key});

  @override
  State<AnimatedFunkyDrawer> createState() => _AnimatedFunkyDrawerState();
}

class _AnimatedFunkyDrawerState extends State<AnimatedFunkyDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'مشاركاتي', 'icon': Icons.edit_note_rounded},
    {'title': 'إشارات مرجعية', 'icon': Icons.bookmark_border_rounded},
    {'title': 'الإحصائيات', 'icon': Icons.insights_rounded},
    {'title': 'المكافآت', 'icon': Icons.workspace_premium_rounded},
    {'title': 'الإعدادات', 'icon': Icons.settings_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Drawer(
      backgroundColor: colors.surfaceContainerLowest,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header Component
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(40 * (1 - value), 0),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.hive_rounded,
                        color: colors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "أهلاً لـ Dallni!",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(indent: 24, endIndent: 24),
            const SizedBox(height: 16),

            // Staggered Animated List Options
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];

                  // Native delay scaling
                  final animationDelay = 0.1 * index;

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Custom staggered offset math matching standard Funky UI approaches
                      final double progress =
                          ((_controller.value - animationDelay) /
                                  (1.0 - animationDelay))
                              .clamp(0.0, 1.0);
                      final double curvedValue = Curves.easeOutBack.transform(
                        progress,
                      );

                      return Transform.translate(
                        offset: Offset(50 * (1 - curvedValue), 0),
                        child: Opacity(
                          opacity: progress.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (item['title'] == 'إشارات مرجعية') {
                              Navigator.of(context).pop(); // Close drawer
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SavedQuestionsScreen(),
                                ),
                              );
                            }
                          },
                          hoverColor: colors.primary.withOpacity(0.05),
                          splashColor: colors.primary.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
