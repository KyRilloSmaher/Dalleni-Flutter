import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_widgets.dart';
import '../screens/saved_questions_screen.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_controller.dart';
import '../widgets/profile_activity.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../screens/edit_profile_screen.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({
    super.key,
    required this.profile,
    required this.isLoading,
    required this.errorMessage,
  });

  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading && profile == null) {
      return const AppLoadingState();
    }

    if (errorMessage != null && profile == null) {
      return AppErrorState(
        message: errorMessage!,
        onRetry: () {
          ref.read(profileControllerProvider.notifier).refreshProfile();
        },
      );
    }

    if (profile == null) {
      return const AppEmptyState(
        title: 'No Profile Found',
        subtitle: 'We could not load your profile.',
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(profileControllerProvider.notifier).refreshProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: kToolbarHeight + 32, bottom: 100),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                ProfileHeader(
                  profile: profile!,
                  onEditProfile: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileStats(profile: profile!),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProfileActivity(
                    profile: profile!,
                    onSavedQuestionsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SavedQuestionsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
