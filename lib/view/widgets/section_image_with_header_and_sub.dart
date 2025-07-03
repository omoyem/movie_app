import 'package:flutter/cupertino.dart';

import '../../constants/images.dart';

class SectionImageWithHeaderAndSub extends StatelessWidget {
  final String headerTitle;
  final String subHeading;
  final String imageString;

  const SectionImageWithHeaderAndSub(
      {Key? key,
      required this.headerTitle,
      required this.imageString,
      required this.subHeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      height: 240.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160.0,
            height: 180.0,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(imageString), fit: BoxFit.fitHeight)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              headerTitle,
              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              subHeading,
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}
