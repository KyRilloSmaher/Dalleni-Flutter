import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/app/app_entry_controller.dart';
import '../../../auth/presentation/providers/login_provider.dart';
import '../../../user/domain/entities/user_profile.dart';
import '../providers/profile_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildBlurredAppBar(context, colors, l10n),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            if (state.profile != null)
              _buildProfileHeader(colors, state.profile!),
            const SizedBox(height: 32),

            _buildSectionHeader(
              colors,
              l10n.translate('settingsSystemConfig') ?? 'SYSTEM CONFIGURATION',
            ),
            const SizedBox(height: 16),

            _buildSettingMenuItem(
              colors: colors,
              icon: Icons.security_rounded,
              title: l10n.translate('settingsSecurity') ?? 'Security',
              subtitle:
                  l10n.translate('settingsSecurityDesc') ??
                  'Passwords, Biometrics',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingMenuItem(
              colors: colors,
              icon: Icons.notifications_none_rounded,
              title: l10n.translate('settingsNotifications') ?? 'Notifications',
              subtitle:
                  l10n.translate('settingsNotificationsDesc') ??
                  'Push, Email, SMS',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildLanguageMenuItem(context, colors, l10n, ref),

            const SizedBox(height: 12),
            _buildDisplayThemeItem(context, colors, l10n, ref),

            const SizedBox(height: 32),
            _buildSectionHeader(
              colors,
              l10n.translate('settingsHelpPrivacy') ?? 'HELP & PRIVACY',
            ),
            const SizedBox(height: 16),

            _buildSettingMenuItem(
              colors: colors,
              icon: Icons.help_outline_rounded,
              title: l10n.translate('settingsHelp') ?? 'Help & Support',
              subtitle:
                  l10n.translate('settingsHelpDesc') ?? 'FAQs, Contact Us',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingMenuItem(
              colors: colors,
              icon: Icons.privacy_tip_outlined,
              title: l10n.translate('settingsPrivacy') ?? 'Privacy Policy',
              subtitle:
                  l10n.translate('settingsPrivacyDesc') ??
                  'Data usage & Policies',
              onTap: () {},
            ),

            const SizedBox(height: 48),
            _buildLogoutButton(context, colors, l10n, ref),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBlurredAppBar(
    BuildContext context,
    DalleniColors colors,
    AppLocalizations l10n,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: colors.surfaceContainerLow.withOpacity(0.7),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              l10n.translate('navProfile') ?? 'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            actions: [
              IconButton(
                // Settings action icon required by prompt
                icon: Icon(
                  Icons.settings_suggest_outlined,
                  color: colors.onSurface,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(DalleniColors colors, UserProfile profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: colors.surfaceContainerHighest,
              backgroundImage:
                  profile.profileImageUrl != null &&
                      profile.profileImageUrl!.isNotEmpty
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child:
                  profile.profileImageUrl == null ||
                      profile.profileImageUrl!.isEmpty
                  ? Icon(Icons.person, size: 48, color: colors.primary)
                  : null,
            ),
            if (profile.reputation > 500) // Positioned verified badge
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified, color: colors.primary, size: 24),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Expert Contributor", // Natively requested subtitle stub
          style: TextStyle(color: colors.onSurfaceVariant, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text("Elite", style: TextStyle(color: colors.onSurface)),
              backgroundColor: colors.surfaceContainerHighest,
              side: BorderSide.none,
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                "Member since 2022",
                style: TextStyle(color: colors.onSurface),
              ),
              backgroundColor: colors.surfaceContainerHighest,
              side: BorderSide.none,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(DalleniColors colors, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: colors.onSurfaceVariant,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingMenuItem({
    required DalleniColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailingOverride,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Using very low blur radius and opacity as requested for glass/soft shadow html replication
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16), // rounded-xl
                  ),
                  child: Icon(icon, color: colors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                trailingOverride ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageMenuItem(
    BuildContext context,
    DalleniColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return _buildSettingMenuItem(
      colors: colors,
      icon: Icons.language_rounded,
      title: l10n.translate('settingsLanguage') ?? 'Language',
      subtitle:
          l10n.translate('settingsLanguageDesc') ??
          'Select your preferred language',
      trailingOverride: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              Localizations.localeOf(context).languageCode.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
      onTap: () {
        // Placeholder for Language toggle or bottom sheet
      },
    );
  }

  Widget _buildDisplayThemeItem(
    BuildContext context,
    DalleniColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    final themeMode = ref.watch(themeControllerProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return _buildSettingMenuItem(
      colors: colors,
      icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      title: l10n.translate('settingsTheme') ?? 'Display Theme',
      subtitle:
          l10n.translate('settingsThemeDesc') ?? 'System Default, Dark, Light',
      trailingOverride: Switch(
        value: isDark,
        activeColor: colors.primary,
        onChanged: (val) {
          ref
              .read(themeControllerProvider.notifier)
              .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
        },
      ),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    DalleniColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.errorContainer,
          foregroundColor: colors.onErrorContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          ref.read(appEntryControllerProvider.notifier).logout();
        },
        child: Text(
          l10n.translate('settingsLogout') ?? 'Logout Account',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
