

import 'package:flutter/material.dart';

class BigAppText extends StatelessWidget {
  final String text;
  final int size;
  final int? maxLines;
  final Color? color;
  final double? lineHeight;
  final TextAlign textAlign;
  final bool? useElips;
  final FontWeight? fontWeight;
  const BigAppText({Key? key, required this.text, this.textAlign = TextAlign.left, required this.size, this.color, this.fontWeight, this.useElips = false, this.maxLines = 3,  this.lineHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines!,
      textAlign: textAlign,
      overflow: useElips! ? TextOverflow.ellipsis : TextOverflow.visible,
      style: TextStyle(
          fontWeight: fontWeight ?? FontWeight.normal,
          fontFamily: 'Lato',
          fontSize: size.toDouble(),
          height: lineHeight ?? 1.3,
          color: color ?? Colors.black
      ),
    );
  }
}
