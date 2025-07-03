import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'banner_placeholder.dart';

class DefaultLoadingShimmer extends StatelessWidget {
  const DefaultLoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 900),
        enabled: true,
        child: const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                ContentPlaceholder(
                  lineType: ContentLineType.threeLines,
                ),
                SizedBox(height: 16.0),
              ],
            )));
  }
}
