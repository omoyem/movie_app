import 'package:flutter/material.dart';
import 'package:godly_seed_app/view/widgets/custom_container_widget.dart';


class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return CustomContainer(
        elevation: 4,
        borderRadius: 10,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        backgroundColor: theme.cardColor,
        child: child);
  }
}
