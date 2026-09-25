import 'package:flutter/material.dart';

import '../../../../core/widgets/state_widgets.dart';

class QuestionDetailsErrorWidget extends StatelessWidget {
  const QuestionDetailsErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppErrorState(
          message: errorMessage,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
