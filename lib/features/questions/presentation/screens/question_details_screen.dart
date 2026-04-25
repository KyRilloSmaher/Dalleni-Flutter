import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dalleni_theme.dart';
import '../../../../core/widgets/common_glass_app_bar.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/question_details_controller.dart';
import '../widgets/answer_card.dart';
import '../widgets/question_card.dart';
import 'category_questions_screen.dart';

class QuestionDetailsScreen extends ConsumerWidget {
  const QuestionDetailsScreen({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.dalleniColors;
    final state = ref.watch(questionDetailsControllerProvider(question.id));

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: const CommonGlassAppBar(
        title: "تفاصيل السؤال",
      ), // "Question Details"
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Padding sliver to offset beneath Glass App Bar natively
          const SliverPadding(
            padding: EdgeInsets.only(top: kToolbarHeight + 40),
          ),

          // Hero Question Context
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Hero(
                tag: 'question_${question.id}',
                child: QuestionCard(
                  question: question,
                  isDetailsView: true,
                  onCategoryTap: (categoryId, categoryName) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryQuestionsScreen(
                          categoryId: categoryId,
                          categoryName: categoryName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Answers Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Text(
                'الإجابات (${state.answers.length})', // "Answers (count)"
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),

          // Answers State Mapping
          if (state.isLoading)
            const SliverToBoxAdapter(child: AppLoadingState())
          else if (state.errorMessage != null)
            SliverToBoxAdapter(
              child: AppErrorState(
                message: state.errorMessage!,
                onRetry: () => ref
                    .read(
                      questionDetailsControllerProvider(question.id).notifier,
                    )
                    .refresh(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final answer = state.answers[index];
                  return AnswerCard(
                    answer: answer,
                    onUpvote: () => ref
                        .read(
                          questionDetailsControllerProvider(
                            question.id,
                          ).notifier,
                        )
                        .upvoteAnswer(answer.id),
                    onDownvote: () => ref
                        .read(
                          questionDetailsControllerProvider(
                            question.id,
                          ).notifier,
                        )
                        .downvoteAnswer(answer.id),
                  );
                }, childCount: state.answers.length),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
        ],
      ),
    );
  }
}
