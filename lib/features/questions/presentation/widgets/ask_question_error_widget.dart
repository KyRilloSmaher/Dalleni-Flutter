import 'package:flutter/material.dart';

import '../../../../core/widgets/state_widgets.dart';

class AskQuestionErrorWidget extends StatelessWidget {
  const AskQuestionErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      message: errorMessage,
      onRetry: onRetry,
    );
  }
}
