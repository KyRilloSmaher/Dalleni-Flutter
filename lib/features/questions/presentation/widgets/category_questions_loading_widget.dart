import 'package:flutter/material.dart';

import '../../../../core/widgets/state_widgets.dart';

class CategoryQuestionsLoadingWidget extends StatelessWidget {
  const CategoryQuestionsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoadingState();
  }
}
