import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:movie_app/constants/images.dart';

class CustomLoadingDialog extends StatelessWidget {
  CustomLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.40,
        width: MediaQuery.sizeOf(context).width * 0.70,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
        ),
        child: _buildUI(context),
      ),
    );
  }

  Widget _buildUI(BuildContext context) {
    return Center(
      child: Image.asset(
        loadingGif, 
        height: 120,
        width: 120,
        fit: BoxFit.contain,
      ),
    );
  }
}

void showLoadingDialog() {
  Get.dialog(
    CustomLoadingDialog(),
    barrierDismissible: true, // Prevent dismissing by tapping outside
  );
}

void hideLoadingDialog() {
  Get.back(); // Close the dialog
}
