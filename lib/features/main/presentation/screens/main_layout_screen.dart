import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../questions/presentation/screens/ask_question_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../questions/presentation/screens/home_feed_screen.dart';
import '../../../services/presentation/screens/services_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 2; // Default to Home (Center)

  // Pages corresponding to each Bottom Navigation item
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 0: Services, 1: Ask, 2: Home, 3: ChatBot, 4: Profile
    _pages = [
      const ServicesScreen(),
      const AskQuestionScreen(),
      const HomeFeedScreen(),
      const Center(child: Text('ChatBot Placeholder')),
      const ProfileScreen(),
    ];
  }

  void _onItemSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
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
      NavItem(icon: Icons.home_rounded, label: l10n.translate('navHome')),
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
      extendBody: true, // Needed for transparent/glassmorphism navbar effect
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        items: navItems,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
