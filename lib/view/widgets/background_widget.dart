import 'package:flutter/material.dart';
import 'package:godly_seed_app/constants/images.dart';

class BackgroundImageWidget extends StatelessWidget {
  final Widget child;
  final String? imageUrl;
  final String? assetPath;
  final BoxFit fit;
  final Color? overlayColor;
  final double overlayOpacity;
  final AlignmentGeometry alignment;

  const BackgroundImageWidget({
    Key? key,
    required this.child,
    this.imageUrl,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.alignment = Alignment.center,
  }) : assert(imageUrl != null || assetPath != null, 
        appBackground),
       super(key: key);


  const BackgroundImageWidget.network({
    Key? key,
    required this.child,
    required String imageUrl,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.alignment = Alignment.center,
  }) : imageUrl = imageUrl,
       assetPath = null,
       super(key: key);

  
  const BackgroundImageWidget.asset({
    Key? key,
    required this.child,
    required String assetPath,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.0,
    this.alignment = Alignment.center,
  }) : assetPath = assetPath,
       imageUrl = null,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _getImageProvider(),
          fit: fit,
          alignment: alignment,
        ),
      ),
      child: overlayOpacity > 0.0
          ? Container(
              decoration: BoxDecoration(
                color: (overlayColor ?? Colors.black).withOpacity(overlayOpacity),
              ),
              child: child,
            )
          : child,
    );
  }

  ImageProvider _getImageProvider() {
    if (imageUrl != null) {
      return NetworkImage(imageUrl!);
    } else if (assetPath != null) {
      return AssetImage(assetPath!);
    } else {
      throw Exception('No image source provided');
    }
  }
}