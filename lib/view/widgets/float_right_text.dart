import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/color_palette.dart';

class FloatRightText extends StatelessWidget {
  final String? text;
  final bool? isBold;
  final bool? isRight;
  final bool? isTitle;
  final Color? color;
  final VoidCallback? onPress;

  const FloatRightText(
      {Key? key,
      this.color,
      this.isTitle = false,
      required this.text,
      this.isBold = true,
      this.isRight = true,
      this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
      onTap: onPress,
      child: Row(
        mainAxisAlignment:
            isRight! ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            text!,
            style: theme.textTheme.bodySmall!.copyWith(
                color: color ?? Theme.of(context).primaryColor,
                fontSize: isTitle! ? 24 : 14,
                fontWeight: isTitle!
                    ? FontWeight.w600
                    : (isBold! ? FontWeight.bold : FontWeight.normal)),
          )
        ],
      ),
    );
  }
}
