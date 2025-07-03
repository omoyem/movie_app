import 'package:flutter/material.dart';
import 'package:godly_seed_app/constants/app_router.dart';

class ForgotPasswordWidget extends StatelessWidget {
  final VoidCallback? onForgotPasswordTap;
  
  const ForgotPasswordWidget({
    Key? key,
    this.onForgotPasswordTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onForgotPasswordTap ?? () => AppRouter.toForgotPassword(),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.orange[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}