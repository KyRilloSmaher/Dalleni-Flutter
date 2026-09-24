import 'package:dalleni/features/profile/presentation/providers/profile_controller.dart';
import 'package:dalleni/features/profile/presentation/widgets/activity_card.dart';
import 'package:dalleni/features/questions/presentation/providers/home_feed_controller.dart';
import 'package:dalleni/features/questions/presentation/screens/question_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';

class SavedQuestionsScreen extends ConsumerStatefulWidget {
  const SavedQuestionsScreen({super.key});

  @override
  ConsumerState<SavedQuestionsScreen> createState() =>
      _SavedQuestionsScreenState();
}

class _SavedQuestionsScreenState extends ConsumerState<SavedQuestionsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).fetchSavedQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final colors = context.dalleniColors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: const CommonGlassAppBar(title: 'My Saved Questions'),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.isLoading && state.savedQuestions.isEmpty) {
      return const AppLoadingState();
    }

    if (state.savedQuestions.isEmpty) {
      return AppEmptyState(
        title: 'لا يوجد أسئلة محفوظة',
        subtitle: 'ابدأ بحفظ الأسئلة التي تهمك للرجوع إليها لاحقاً.',
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(profileControllerProvider.notifier)
            .fetchSavedQuestions();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 40),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.savedQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final savedQuestion = state.savedQuestions[index];

          return ActivityCard(
            savedQuestion: savedQuestion,
            isNeed: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuestionDetailsScreen(question: state.savedQuestions[index].question),
                ),
              );
            },
            onRemove: () async {
              await ref
                  .read(homeFeedControllerProvider.notifier)
                  .toggleSaveQuestion(savedQuestion.question);
              await ref
                  .read(profileControllerProvider.notifier)
                  .fetchSavedQuestions();
            },
          );
        },
      ),
    );
  }
}
