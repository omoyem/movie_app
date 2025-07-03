import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants/color_palette.dart';
import 'animation_widgets/slidein_up_anim.dart';

class CustomBoxButton extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final Widget? icon;
  final bool isLoading;
  final bool outlined;
  final double? borderRadius;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const CustomBoxButton(
      {Key? key,
      required this.label,
      this.icon,
      this.isLoading = false,
      this.outlined = false,
      this.backgroundColor,
      this.labelColor,
      this.borderRadius,
      required this.onPressed, required String text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideInAnimationWidget(
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory, // Removes splash effect
                overlayColor: (Colors.transparent), // Removes highlight color
              ),
              onPressed: isLoading ? null : onPressed,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius ?? 22),
                    color: outlined
                        ? null
                        : backgroundColor ?? Theme.of(context).primaryColor,
                    border: outlined ? Border.all(color: primaryColor) : null),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: icon == null
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.center,
                        children: [
                            const SpinKitFadingCircle(
                              size: 30.0,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Please wait",
                              style:
                                  TextStyle(color: labelColor ?? Colors.white),
                            )
                          ])
                    : Row(
                        mainAxisAlignment: icon == null
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.center,
                        children: [
                            icon ?? const SizedBox(),
                            icon != null
                                ? const SizedBox(
                                    width: 20.0,
                                  )
                                : const SizedBox(),
                            Text(
                              label,
                              style: TextStyle(
                                  color: outlined
                                      ? labelColor ?? primaryColor
                                      : labelColor ?? Colors.white),
                            )
                          ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
