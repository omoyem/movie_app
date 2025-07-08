import 'package:flutter/material.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/view/onboarding/models/onboarding_data_model.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingData data;

  const OnboardingCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
         
            Container(
              width: 250,
              height: 200,
              child: data.image,
            ),
            SizedBox(height: 48),
            Text(
              data.title,
              style: TextStyle(
                fontSize: 34,
                fontFamily: 'FunkySmile',
                fontWeight: FontWeight.bold,
                color: data.titleColor ?? Colors.black12,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              data.description,
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w300,
                fontSize: 14,
                color: data.descriptionColor ?? primaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 