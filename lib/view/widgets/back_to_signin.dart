import 'package:flutter/material.dart';

class BackToSignInWidget extends StatelessWidget {
  final VoidCallback onBackToSignInTap;
  
  const BackToSignInWidget({
    Key? key,
    required this.onBackToSignInTap,
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
            TextSpan(text: 'Remember your password? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: onBackToSignInTap,
                child: Text(
                  'BACK TO SIGN IN',
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