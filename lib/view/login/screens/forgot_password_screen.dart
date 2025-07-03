import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';
import 'package:godly_seed_app/view/widgets/back_to_signin.dart';
import 'package:godly_seed_app/view/widgets/background_widget.dart';
import 'package:godly_seed_app/view/widgets/custom_button.dart';
import 'package:godly_seed_app/view/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageWidget.asset(
        assetPath: appBackground,
        fit: BoxFit.cover,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 
                            MediaQuery.of(context).padding.bottom - 48,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Logo centered at top
                Center(
                  child: AppLogoWidget(size: 160),
                ),
                SizedBox(height: 40),
                
                // Forgot Password title aligned to start
                Text(
                  'FORGOT PASSWORD',
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'FunkySmile',
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                
                // Reset Password button
                CustomButton(
                  text: 'Reset Password',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Get.snackbar(
                        'Success',
                        'Password reset link sent to ${_emailController.text}',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: Duration(seconds: 3),
                      );
                    
                      Future.delayed(Duration(seconds: 1), () {
                        AppRouter.toLogin();
                      });
                    }
                  },
                  label: '',
                ),
                SizedBox(height: 32),
                
                BackToSignInWidget(
                  onBackToSignInTap: () => AppRouter.toLogin(),
                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}