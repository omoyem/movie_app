import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:movie_app/constants/images.dart';
import 'package:movie_app/view/reset_password/controllers/reset_password_controller.dart';
import 'package:movie_app/view/sign_up/controller/signup_controller.dart';
import 'package:movie_app/view/sign_up/screens/signup_screen.dart';
import 'package:movie_app/view/widgets/app_logo_widget.dart';
import 'package:movie_app/view/widgets/background_widget.dart';
import 'package:movie_app/view/widgets/custom_button.dart';

import '../../login/screens/login_screen.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final SignupController _signupController = Get.find<SignupController>();

  var autoValidationMode = AutovalidateMode.disabled;
  ResetPasswordController resetPasswordController = Get.put(ResetPasswordController());
  final _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _remainingTime = 300;
  bool _canResend = false;


  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingTime = 300;
    _canResend = false;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageWidget.asset(
        assetPath: appBackground,
        fit: BoxFit.cover,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'FunkySmile',
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),

                        // Subtitle
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(text: 'Password reset for\n'),
                              TextSpan(
                                text: widget.email,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        // OTP Input Fields
                        Form(
                          key: _formKey,
                          autovalidateMode: autoValidationMode,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: resetPasswordController.passwordController,
                                label: 'New Password',
                                hint: 'Enter new password',
                                prefixIcon: Icons.lock_outline,
                                keyboardType: TextInputType.text,
                              isPassword: true,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  if (resetPasswordController.passwordController.text != resetPasswordController.confirmPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              // OTP Input Fields
                              CustomTextField(
                                controller: resetPasswordController.confirmPasswordController,
                                label: 'Confirm Password',
                                hint: 'Confirm new password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter confirm password';
                                  }
                                  if (resetPasswordController.passwordController.text != resetPasswordController.confirmPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),


                        Obx(() => CustomButton(
                              text: _signupController.isLoading.value
                                  ? 'Submitting...'
                                  : 'Submit',
                              onPressed: _handleVerifyOtp,
                            )),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerifyOtp() async {

setState(() {
  autoValidationMode = AutovalidateMode.onUserInteraction;
});
    if(_formKey.currentState!.validate()) {
      final success = await resetPasswordController.resetPassword(
          widget.email);

      if (success) {
        Get.off(() => SignInScreen());
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
