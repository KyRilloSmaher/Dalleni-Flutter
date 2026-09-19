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

class QuestionDetailsScreen extends ConsumerStatefulWidget {
  const QuestionDetailsScreen({super.key, required this.question});

  final Question question;

  @override
  ConsumerState<QuestionDetailsScreen> createState() =>
      _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends ConsumerState<QuestionDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();

  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    final state = ref.watch(
      questionDetailsControllerProvider(widget.question.id),
    );

    final controller = ref.read(
      questionDetailsControllerProvider(widget.question.id).notifier,
    );

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,

      appBar: const CommonGlassAppBar(title: 'Question'),

      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.only(top: kToolbarHeight + 32),
          ),

          // =========================
          // QUESTION / POST
          // =========================
          SliverToBoxAdapter(
            child: Hero(
              tag: 'question_${widget.question.id}',
              child: QuestionCard(
                question: widget.question,
                isDetailsView: true,
                onCategoryTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryQuestionsScreen(
                        categoryId: widget.question.categoryId ?? "",
                        categoryName: widget.question.categoryName ?? "",
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // =========================
          // ANSWERS HEADER
          // =========================
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              color: colors.surface,
              child: Row(
                children: [
                  Text(
                    'Answers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${state.answers.length}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // ANSWERS
          // =========================
          if (state.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: AppLoadingState(),
              ),
            )
          else if (state.errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppErrorState(
                  message: state.errorMessage!,
                  onRetry: controller.refresh,
                ),
              ),
            )
          else if (state.answers.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 20,
                ),
                color: colors.surface,
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 44,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No answers yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first one to answer this question.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final answer = state.answers[index];

                return AnswerCard(
                  answer: answer,
                  questionId: widget.question.id,
                );
              }, childCount: state.answers.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),

      // =========================
      // COMMENT INPUT
      // =========================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // =========================
              // AVATAR
              // =========================
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 8),

              // =========================
              // TEXT FIELD
              // =========================
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // =========================
              // SEND BUTTON
              // =========================
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _commentController,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;

                  return IconButton(
                    onPressed: hasText
                        ? () {
                            controller.createComment(value.text);
                            _commentController.clear();
                            _commentFocusNode.unfocus();
                          }
                        : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: hasText
                          ? colors.primary
                          : colors.onSurfaceVariant.withOpacity(0.4),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
