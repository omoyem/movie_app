// Horizontal Spacer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/images.dart';
import '../../utils/helpers.dart';


class AuthHeaderWidget extends StatelessWidget {
  final double? paddingBottom;

  const AuthHeaderWidget({super.key, this.paddingBottom});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: deviceHeight(context) * 0.3,
      width: deviceWidth(context),
      child: Stack(
        children: [
          Image.asset(
            appBackground,
            fit: BoxFit.fill,
            width: deviceWidth(context),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Center(
                child: Image.asset(appLogo,
                    fit: BoxFit.contain, height: 45.0)),
          )
        ],
      ),
    );
  }
}
