import 'package:flutter/cupertino.dart';
import 'package:godly_seed_app/constants/images.dart';


class AppLogoWidget extends StatelessWidget {
  final double? size;

  const AppLogoWidget({Key? key, this.size = 90}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(appLogo))),
        )
      ],
    );
  }
}
