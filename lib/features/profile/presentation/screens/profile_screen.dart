import 'package:dalleni/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/animated_funky_drawer.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../questions/presentation/screens/saved_questions_screen.dart';
import '../../../user/domain/entities/user_profile.dart';
import '../providers/profile_controller.dart';
import 'edit_profile_screen.dart';
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
        title: l10n.translate('navProfile') ?? 'Profile',
        trailingActions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.onSurface),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: state.isLoading && state.profile == null
          ? const AppLoadingState()
          : state.errorMessage != null && state.profile == null
          ? AppErrorState(
              message: state.errorMessage!,
              onRetry: () =>
                  ref.read(profileControllerProvider.notifier).refreshProfile(),
            )
          : state.profile == null
          ? AppEmptyState(
              title: 'No Profile Found',
              subtitle: 'We could not load your profile.',
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(profileControllerProvider.notifier).refreshProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: kToolbarHeight + 40,
                  left: 16,
                  right: 16,
                  bottom: 120,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth > 600;
                    if (isTablet) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _ProfileSidebar(profile: state.profile!),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _ContributionsSection(
                              profile: state.profile!,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileHeader(profile: state.profile!),
                        const SizedBox(height: 16),
                        _StatsGrid(profile: state.profile!),
                        const SizedBox(height: 16),
                        _ContributionsSection(profile: state.profile!),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colors.surfaceContainerHighest,
            backgroundImage:
                profile.profileImageUrl != null &&
                    profile.profileImageUrl!.isNotEmpty
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child:
                profile.profileImageUrl == null ||
                    profile.profileImageUrl!.isEmpty
                ? Icon(Icons.person, size: 50, color: colors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.fullName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              if (profile.reputation > 500) ...[
                const SizedBox(width: 4),
                Icon(Icons.verified, color: colors.primary, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@${profile.userName}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: l10n.translate('updateProfileButton'),
            isOutlined: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.translate('statsReputation'),
            value: profile.reputation.toString(),
            icon: Icons.star_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.translate('statsQuestions'),
            value: profile.questionsCount.toString(),
            icon: Icons.help_outline_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: l10n.translate('statsAnswers'),
            value: profile.answersCount.toString(),
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  const _ProfileSidebar({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileHeader(profile: profile),
        const SizedBox(height: 16),
        _StatsGrid(profile: profile),
      ],
    );
  }
}

class _ContributionsSection extends StatelessWidget {
  const _ContributionsSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'نشاطي', // My Activity
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.bookmark_rounded, color: colors.primary),
              title: const Text('الأسئلة المحفوظة'),
              trailing: const Icon(Icons.chevron_right_rounded),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SavedQuestionsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.help_outline_rounded,
                color: colors.secondary,
              ),
              title: const Text('أسئلتي'),
              subtitle: Text('${profile.questionsCount} سؤال'),
              trailing: const Icon(Icons.chevron_right_rounded),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                // Future: Navigate to My Questions
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
              title: const Text('إجاباتي'),
              subtitle: Text('${profile.answersCount} إجابة'),
              trailing: const Icon(Icons.chevron_right_rounded),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                // Future: Navigate to My Answers
              },
            ),
          ],
        ),
      ),
    );
  }
}
