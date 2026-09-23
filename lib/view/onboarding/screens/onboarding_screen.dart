import 'package:flutter/material.dart';
import 'package:movie_app/constants/app_router.dart';
import 'package:movie_app/constants/color_palette.dart';

import 'package:movie_app/constants/images.dart';
import 'package:movie_app/view/onboarding/models/onboarding_data_model.dart';
import 'package:movie_app/view/widgets/app_logo_widget.dart';
import 'package:movie_app/view/widgets/background_widget.dart';
import 'package:movie_app/view/widgets/custom_button.dart';
import 'package:movie_app/view/widgets/onboarding_card.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int currentIndex = 0;

  
  List<OnboardingData> get onboardingData => [
    OnboardingData.fromAsset(
      title: 'Welcome to Movie App',
      description: 'Stream movies and shows for the whole family, all in one place.',
      assetPath: onboarding1,
      imageBorderRadius: BorderRadius.circular(20),
      imagePadding: const EdgeInsets.all(20),
      titleColor: campusColor,
      descriptionColor:campusColor,
    ),
    OnboardingData.fromAsset(
      title: 'Watch Anywhere',
      description: 'Download movies to your phone and keep watching even when you are offline.',
      assetPath: onboarding2,
      imageBorderRadius: BorderRadius.circular(20),
      imagePadding: const EdgeInsets.all(20),
      titleColor: campusColor,
      descriptionColor: campusColor,
    ),
    OnboardingData.fromAsset(
      title: 'Your Personal Watchlist',
      description: 'Sign up to save favourites, pick up where you left off, and create a profile for everyone at home.',
      assetPath: onboarding3,
      imageBorderRadius: BorderRadius.circular(20),
      imagePadding: const EdgeInsets.all(20),
      titleColor:campusColor,
      descriptionColor: campusColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageWidget.asset(
        assetPath: appBackground,
        fit: BoxFit.cover,
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: AppLogoWidget(size: 160),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingCard(data: onboardingData[index]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? primaryColor
                              : Colors.brown[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: currentIndex == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    label: '', 
                    onPressed: () {
                      if (currentIndex == onboardingData.length - 1) {
                        AppRouter.toGetStarted();
                      } else {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  if (currentIndex < onboardingData.length - 1)
                    TextButton(
                      onPressed: () => AppRouter.toGetStarted(),
                      child: Text(
                        'Skip',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}