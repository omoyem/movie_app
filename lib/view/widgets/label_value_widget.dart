import 'package:flutter/material.dart';

import '../../constants/color_palette.dart';
import 'big_app_text.dart';
import 'custom_container_widget.dart';

class LabelValueWidget extends StatelessWidget {
  final String label;
  final String value;

  const LabelValueWidget({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CustomContainer(
          borderRadius: 10,
          padding: EdgeInsets.all(12),
          borderColor: kLightTextColor.withOpacity(0.3),
          child: Row(
            children: [
              Expanded(child: BigAppText(text: label, size: 14)),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BigAppText(text: value, color: theme.primaryColor, size: 14),
                ],
              )),
            ],
          )),
    );
  }
}
