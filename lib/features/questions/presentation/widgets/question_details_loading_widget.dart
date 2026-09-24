import 'package:flutter/material.dart';

import 'fb_post_skeleton.dart';

class QuestionDetailsLoadingWidget extends StatelessWidget {
  const QuestionDetailsLoadingWidget({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FbFeedSkeletonList(count: count),
    );
  }
}
