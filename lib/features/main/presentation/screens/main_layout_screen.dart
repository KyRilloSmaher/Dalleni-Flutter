import 'package:dalleni/features/notifications/presentation/providers/notification_controller.dart';
import 'package:dalleni/features/official_entities/presentation/screens/official_entities_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../questions/presentation/screens/ask_question_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../questions/presentation/screens/home_feed_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 2;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const OfficialEntitiesScreen(),
      const AskQuestionScreen(),
      const HomeFeedScreen(),
      const Center(
        child: Text('ChatBot Placeholder'),
      ),
      const ProfileScreen(),
    ];

    Future.microtask(_initializeFCM);
  }

  Future<void> _initializeFCM() async {
    try {
      await ref
          .read(notificationControllerProvider.notifier)
          .initializeFCM();

      debugPrint('[FCM DEBUG] FCM initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('[FCM DEBUG] FCM initialization failed: $e');
      debugPrint('[FCM DEBUG] FCM stack trace: $stackTrace');

    
    }
  }

  void _onItemSelected(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final navItems = [
      NavItem(
        icon: Icons.grid_view_rounded,
        label: l10n.translate('navServices'),
      ),
      NavItem(
        icon: Icons.add_circle_outline_rounded,
        label: l10n.translate('navAsk'),
      ),
      NavItem(
        icon: Icons.home_rounded,
        label: l10n.translate('navHome'),
      ),
      NavItem(
        icon: Icons.chat_bubble_outline_rounded,
        label: l10n.translate('navChat'),
      ),
      NavItem(
        icon: Icons.person_outline_rounded,
        label: l10n.translate('navProfile'),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        items: navItems,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}