import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/color_palette.dart';
import '../../constants/images.dart';
import '../../utils/helpers.dart';
import 'big_app_text.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {super.key,
      this.padding = const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
       this.child,
      this.backgroundColor,
      this.borderRadius = 0,
      this.elevation = 0,
      this.borderWidth = 1.0,
      this.borderColor,
      this.onTap,
      this.width,
      this.height,
      this.backgroundImage, this.networkImage});

  final Widget? child;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? elevation;
  final VoidCallback? onTap;
  final double? height;
  final double? borderWidth;
  final String? backgroundImage;
  final String? networkImage;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius!),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(elevation!),
          child: Material(
            elevation: elevation!,
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius!),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  border: borderColor != null
                      ? Border.all(color: borderColor!, width: borderWidth!)
                      : null,
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius!),
                  image: (backgroundImage != null || networkImage != null)
                      ? DecorationImage(
                          image: networkImage != null
                              ? NetworkImage(networkImage!)
                              : AssetImage(backgroundImage!),
                          fit: BoxFit.cover)
                      : null),
              child: Padding(
                padding: padding!,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
