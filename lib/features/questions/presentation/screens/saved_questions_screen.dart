import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../providers/saved_questions_controller.dart';
import '../widgets/question_card.dart';

class SavedQuestionsScreen extends ConsumerWidget {
  const SavedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedQuestionsControllerProvider);
    final colors = context.dalleniColors;

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: const CommonGlassAppBar(title: 'محفوظاتي'),
      body: state.isLoading && state.questions.isEmpty
          ? const AppLoadingState()
          : state.questions.isEmpty
          ? AppEmptyState(
              title: 'لا يوجد أسئلة محفوظة',
              subtitle: 'ابدأ بحفظ الأسئلة التي تهمك للرجوع إليها لاحقاً.',
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(savedQuestionsControllerProvider.notifier)
                  .fetchSavedQuestions(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  kToolbarHeight + 40,
                  16,
                  40,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final question = state.questions[index];
                  return QuestionCard(
                    question: question,
                    // We can handle upvotes here too if needed
                  );
                },
              ),
            ),
    );
  }
}
