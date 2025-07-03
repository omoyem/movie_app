import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/color_palette.dart';

typedef CustomCallBack = Function(String value);

class OtpBoxWidget extends StatelessWidget {
  final CustomCallBack onChanged;
  final FocusNode focusNode;


  const OtpBoxWidget({Key? key, required this.onChanged, required this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: SizedBox(
        height: 80,
        width: 40,
        child: TextField(
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: onChanged,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: Colors.grey[100]!, width: 0.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: primaryColor),
            ),
            hintStyle: TextStyle(
                color: Colors.grey[700],
                fontSize: 16.0,
                fontWeight: FontWeight.w200),
            contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            isDense: true,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12.0),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),

        ),
      ),
    );
  }
}
