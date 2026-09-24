import 'package:flutter/material.dart';

import '../../../../core/widgets/state_widgets.dart';

class AskQuestionLoadingWidget extends StatelessWidget {
  const AskQuestionLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingState();
  }
}
