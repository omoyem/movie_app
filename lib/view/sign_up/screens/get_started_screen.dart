import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_app/constants/app_router.dart';
import 'package:movie_app/constants/color_palette.dart';
import 'package:movie_app/constants/images.dart';
import 'package:movie_app/view/sign_up/controller/signup_controller.dart';
import 'package:movie_app/view/sign_up/screens/otp_verification_screen.dart';
import 'package:movie_app/view/widgets/app_logo_widget.dart';
import 'package:movie_app/view/widgets/background_widget.dart';
import 'package:movie_app/view/widgets/custom_text_field.dart';
import 'package:movie_app/view/widgets/signin_prompt_widget.dart';
import 'package:movie_app/view/widgets/signup_prompt_widget.dart';

class GetStartedScreen extends StatefulWidget {
  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final SignupController _signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: BackgroundImageWidget.asset(
          assetPath: appBackground,
          fit: BoxFit.cover,
          child: SafeArea(
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
                      SizedBox(height: 40),
                      
                      Center(
                        child: AppLogoWidget(size: 160),
                      ),
                      SizedBox(height: 50),
                      
                      Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 36,
                          fontFamily: 'FunkySmile',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Text(
                        'Enter your email to receive a verification code',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email address',
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
                    
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _signupController.isLoading.value ? null : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final success = await _signupController.sendOtp(_emailController.text.trim());
                              if (success) {
                                Get.to(() => OtpVerificationScreen(email: _emailController.text.trim()));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                          ),
                          child: _signupController.isLoading.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sending...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Send Verification Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      )),
                      SizedBox(height: 32),
                      
                      SignInPromptWidget(
                        onSignInTap: () => AppRouter.toLogin(),
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