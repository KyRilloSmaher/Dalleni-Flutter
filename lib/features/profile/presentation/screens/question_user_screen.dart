import 'package:dalleni/features/profile/presentation/providers/profile_controller.dart';
import 'package:dalleni/features/profile/presentation/widgets/activity_card.dart';
import 'package:dalleni/features/questions/presentation/providers/home_feed_controller.dart';
import 'package:dalleni/features/questions/presentation/screens/question_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';

class QuestionsUserScreen extends ConsumerStatefulWidget {
  const QuestionsUserScreen({super.key});

  @override
  ConsumerState<QuestionsUserScreen> createState() =>
      _SavedQuestionsScreenState();
}

class _SavedQuestionsScreenState extends ConsumerState<QuestionsUserScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).fetchQuestuionUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final colors = context.dalleniColors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: const CommonGlassAppBar(title: 'My Questions'),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.isLoading && state.questionuser.isEmpty) {
      return const AppLoadingState();
    }

    if (state.questionuser.isEmpty) {
      return AppEmptyState(title: 'لا يوجد أسئلة', subtitle: '');
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(profileControllerProvider.notifier)
            .fetchQuestuionUser();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 40),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.questionuser.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final questionuser = state.questionuser[index];
          print('User Question ${questionuser.question.content} in UI');
          return ActivityCard(
            questionUser: questionuser,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuestionDetailsScreen(question: state.questionuser[index].question),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
