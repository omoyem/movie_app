import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constants/color_palette.dart';


Future<dynamic> buildShowDialog({required BuildContext context, bool? showTopPadding= true, bool? showCancelButton = true, Widget? content, title = ""}) {
  return showDialog(
      context: context,

      builder: (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: kWhiteColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(showCancelButton!)
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                title,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Icon(CupertinoIcons.xmark),
                        ],
                      ),
                    ),
                    if(showTopPadding!)
                    SizedBox(height: 20),
                    content!
                  ],
                ),
              ),
            ),
          ));
}
