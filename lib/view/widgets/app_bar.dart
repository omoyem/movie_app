
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_app/constants/color_palette.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool? isTitleCentered;
  final Color? titleColor;
  final VoidCallback? leftOnPress;
  final bool? showBackBtn;
  final VoidCallback? rightOnPress;

  const CustomAppBar(
      {Key? key,
      this.title,
      this.leftIcon,
      this.rightIcon,
        this.titleColor,
      this.isTitleCentered = false,
      this.leftOnPress,
      this.showBackBtn = true,
      this.rightOnPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showBackBtn != null
                ? showBackBtn!
                    ? InkWell(
                        onTap: leftOnPress ?? () => Get.back(),
                        child: leftIcon ??
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor),
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(CupertinoIcons.back, color: primaryColor,),
                              ),
                            ),
                      )
                    : const SizedBox(
                        width: 25,
                        height: 25,
                      )
                : InkWell(
                    onTap: leftOnPress ?? () => Get.back(),
                    child: leftIcon ??
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(12.0)),
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(CupertinoIcons.back, color: primaryColor),
                          ),
                        ),
                  ),
            Text(
              title ?? "",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? kBlackColor,
                  fontSize: 18.0),
            ),
            rightIcon != null
                ? rightIcon!
                : const SizedBox(
                    width: 25,
                    height: 25,
                  ),
          ],
        ),
      ),
    );
  }
}
