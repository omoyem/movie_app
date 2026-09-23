
import 'package:flutter/material.dart';
import 'package:movie_app/view/widgets/custom_button.dart';

import '../../constants/images.dart';
import '../../utils/helpers.dart';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: deviceHeight(context) * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage(noInternetImage),
            height: 100.0,
            width: 100,
          ),
          const SizedBox(
            height: 30.0,
          ),
          SizedBox(
            width: deviceWidth(context) - 50,
            child: const Text(
              "Failed to Load. Kindly Check your internet connection",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20.0, height: 1.8, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          SizedBox(width: deviceWidth(context)/2, child: CustomButton(label: "Retry", onPressed: onRetry, text: '',))
        ],
      ),
    );
  }
}
