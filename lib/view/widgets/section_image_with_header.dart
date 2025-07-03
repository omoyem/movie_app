import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/images.dart';

class SectionImageWithHeader extends StatelessWidget {
  final String headerTitle;
  final String imageString;
  final VoidCallback? onPressed;


  const SectionImageWithHeader({Key? key, required this.headerTitle, required this.imageString, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 165.0,
        height: 220.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 155.0,
              height: 190.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(imageString), fit: BoxFit.fill)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Center(
                child: Text(
                  headerTitle,
                  style: TextStyle(fontSize: 13.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
