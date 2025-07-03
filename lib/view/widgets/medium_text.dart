import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MediumText extends StatelessWidget {
  final String text;
  final bool? isBold;
  final VoidCallback? onPress;
  final TextAlign? textAlign;
  final Color? color;

  const MediumText(
      {Key? key,
      this.textAlign = TextAlign.start,
      this.onPress,
        this.color = Colors.black,
      this.isBold = false,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPress,
        child: Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
              fontSize: 18.0, color: color!,
              fontWeight: isBold! ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}
