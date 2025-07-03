import 'package:flutter/material.dart';

class FeaturedTestimonyItem extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const FeaturedTestimonyItem({Key? key, required this.imageUrl, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              width: 180,
              height: 190.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.fill,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
