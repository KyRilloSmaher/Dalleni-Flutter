import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:dalleni/features/profile/presentation/widgets/profile_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../providers/profile_controller.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      drawer: const AnimatedFunkyDrawer(),
      appBar: CommonGlassAppBar(
        title: l10n.translate('navProfile') ,
        trailingActions: [
          IconButton(
            tooltip: 'Settings',
            icon: Icon(Icons.settings_outlined, color: colors.onSurface),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: ProfileBody(
        profile: state.profile,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
      ),
    );
  }
}
