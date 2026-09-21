import 'package:dalleni/features/profile/domain/entities/user_profile.dart';
import 'package:dalleni/features/profile/presentation/widgets/activity_content.dart';
import 'package:dalleni/features/profile/presentation/widgets/activity_header.dart';
import 'package:dalleni/features/profile/presentation/widgets/footer.dart';
import 'package:dalleni/features/questions/domain/entities/question_entity.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/dalleni_theme.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    this.savedQuestion,
    this.questionUser,
    this.onTap,
    this.onRemove,  this.isNeed = false,
  }) : assert(
          savedQuestion != null || questionUser != null,
          'Either savedQuestion or questionUser must be provided.',
        ),
       assert(
          savedQuestion == null || questionUser == null,
          'Only one of savedQuestion or questionUser can be provided.',
        );

  final SavedQuestion? savedQuestion;
  final QuestionUser? questionUser;
  final bool isNeed;

  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    final question = savedQuestion?.question ?? questionUser!.question;

    final date = savedQuestion?.savedAt ?? questionUser!.savedAt;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ActivityHeader(
                question: question,
                colors: colors,
                savedAt: date,
                onRemove: savedQuestion != null ? onRemove : null,
                isNeed:isNeed ,
              ),

              const SizedBox(height: 14),

              ActivityContent(
                question: question,
                colors: colors,
              ),

              const SizedBox(height: 14),

              Footer(
                colors: colors,
                savedAt: date,
                isNeed: isNeed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}