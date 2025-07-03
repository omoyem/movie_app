import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants/color_palette.dart';
import 'animation_widgets/slidein_up_anim.dart';

class CombinedClickableText extends StatelessWidget {
  final String? firstText;
  final String? secondText;
  final bool? isLoading;
  final VoidCallback? onPress;

  const CombinedClickableText(
      {Key? key, this.onPress, this.isLoading = false, this.firstText, this.secondText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      child: InkWell(
        onTap: onPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${firstText!} ",
                style: const TextStyle(fontSize: 12.0),
              ),
              Text(
                secondText!,
                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              if (isLoading!)
                SpinKitFadingCircle(
                  color: primaryDarkColor,
                  size: 30,
                )
            ],
          ),
        ),
      ),
    );
  }
}
