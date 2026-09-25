import 'package:flutter/material.dart';

import 'fb_post_skeleton.dart';

class HomeFeedLoadingWidget extends StatelessWidget {
  const HomeFeedLoadingWidget({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FbFeedSkeletonList(count: count),
    );
  }
}
