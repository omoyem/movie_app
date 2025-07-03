import 'package:flutter/material.dart';

class SignUpPromptWidget extends StatelessWidget {
  final VoidCallback onSignUpTap;
  
  const SignUpPromptWidget({
    Key? key,
    required this.onSignUpTap,
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
            TextSpan(text: 'Don\'t have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: onSignUpTap,
                child: Text(
                  'SIGN UP',
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