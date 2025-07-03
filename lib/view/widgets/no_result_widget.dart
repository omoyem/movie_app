

import 'package:flutter/material.dart';

import '../../constants/images.dart';
import '../../utils/helpers.dart';

class NoResultWidget extends StatelessWidget {
  final String title;
  final String? image;

  const NoResultWidget({Key? key, required this.title, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: deviceHeight(context) * 0.5,
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage(image ?? emptyRecordsIcon),
            height: 100.0,
            width: 100,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
