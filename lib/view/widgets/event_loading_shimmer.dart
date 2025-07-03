import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/helpers.dart';
import 'banner_placeholder.dart';

class EventLoadingShimmer extends StatelessWidget {
  const EventLoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 900),
        enabled: true,
        child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: ListView(
              shrinkWrap: true,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.33,
                        child: Container(
                          width: deviceWidth(context) - 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40.0),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}
