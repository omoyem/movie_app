import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/color_palette.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? endText;
  final VoidCallback? onPress;

  const SectionHeader({Key? key, required this.title, this.endText, this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Row(
            children: [
              Container(height: 20, width: 5, color: primaryDarkColor,),
              SizedBox(width: 15,),
              Text(
                title,
                style: TextStyle(fontSize: 17.0, color: primaryDarkColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        endText != null
            ? InkWell(
          onTap: () {
            if(endText != null && onPress != null){
              onPress!();
            }
          },
              child: Text(
                  endText!,
                  style: TextStyle(color: secondaryColor),
                ),
            )
            : Container()
      ],
    );
  }
}
