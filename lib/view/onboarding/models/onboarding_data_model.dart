import 'package:flutter/material.dart';

class OnboardingData {
  final String title;
  final String description;
  final Widget image; 
 
  final Color? titleColor;
  final Color? descriptionColor;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.image,

    this.titleColor,
    this.descriptionColor,
  });


  factory OnboardingData.fromAsset({
    required String title,
    required String description,
    required String assetPath,
    double? width,
    double? height,
    BoxFit? fit,
    Color? imageBackground,
    BorderRadius? imageBorderRadius,
    EdgeInsets? imagePadding,
   
    Color? titleColor,
    Color? descriptionColor,
  }) {
    Widget imageWidget = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );

    if (imageBackground != null || imagePadding != null || imageBorderRadius != null) {
      imageWidget = Container(
        padding: imagePadding,
        decoration: BoxDecoration(
          color: imageBackground,
          borderRadius: imageBorderRadius,
        ),
        child: imageWidget,
      );
    }

    return OnboardingData(
      title: title,
      description: description,
      image: imageWidget,
    
      titleColor: titleColor,
      descriptionColor: descriptionColor,
    );
  }

 
  factory OnboardingData.fromNetwork({
    required String title,
    required String description,
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Color? imageBackground,
    BorderRadius? imageBorderRadius,
    EdgeInsets? imagePadding,
   
    Color? titleColor,
    Color? descriptionColor,
  }) {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.error_outline,
          size: 50,
          color: Colors.grey,
        );
      },
    );
    if (imageBackground != null || imagePadding != null || imageBorderRadius != null) {
      imageWidget = Container(
        padding: imagePadding,
        decoration: BoxDecoration(
          color: imageBackground,
          borderRadius: imageBorderRadius,
        ),
        child: imageWidget,
      );
    }

    return OnboardingData(
      title: title,
      description: description,
      image: imageWidget,
    
      titleColor: titleColor,
      descriptionColor: descriptionColor,
    );
  }

 
  OnboardingData copyWith({
    String? title,
    String? description,
    Widget? image,
    Color? backgroundColor,
    Color? titleColor,
    Color? descriptionColor,
  }) {
    return OnboardingData(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
    
      titleColor: titleColor ?? this.titleColor,
      descriptionColor: descriptionColor ?? this.descriptionColor,
    );
  }
}
