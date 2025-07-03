import 'package:flutter/material.dart';
import 'package:godly_seed_app/constants/color_palette.dart';

class SignInPromptWidget extends StatelessWidget {
  final VoidCallback onSignInTap;
  
  const SignInPromptWidget({
    Key? key,
    required this.onSignInTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          children: [
            TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: onSignInTap,
                child: Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[600], 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}