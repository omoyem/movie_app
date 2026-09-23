import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/images.dart';

class SermonCategoryShimmerWidget extends StatelessWidget {
  final String headerTitle;
  final String imageString;

  const SermonCategoryShimmerWidget(
      {Key? key, required this.headerTitle, required this.imageString})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Shimmer.fromColors(
              baseColor: Colors.red,
              highlightColor: Colors.yellow,
              child: Container(
                height: 120.0,
                decoration: BoxDecoration(
                  color: Colors.grey,
                    borderRadius: BorderRadius.circular(15.0),
                   ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
