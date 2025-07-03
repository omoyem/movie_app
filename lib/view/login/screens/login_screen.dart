import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/view/login/controller/login_controller.dart';
import 'package:godly_seed_app/view/sign_up/controller/signup_controller.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';
import 'package:godly_seed_app/view/widgets/background_widget.dart';
import 'package:godly_seed_app/view/widgets/custom_button.dart';
import 'package:godly_seed_app/view/widgets/custom_text_field.dart';
import 'package:godly_seed_app/view/widgets/forgot_password.dart';
import 'package:godly_seed_app/view/widgets/google_signin_button.dart';
import 'package:godly_seed_app/view/widgets/or_divider_widget.dart';
import 'package:godly_seed_app/view/widgets/signup_prompt_widget.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late final SignupController _signUpController;
  late final LoginController _loginController;
  
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    
    _signUpController = Get.put(SignupController());
    _loginController = Get.put(LoginController());
  }

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
                      SizedBox(height: 20),
                      
                      Center(
                        child: AppLogoWidget(size: 160),
                      ),
                      SizedBox(height: 40),
                      
                      Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 36,
                          fontFamily: 'FunkySmile',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      // Form fields
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
                      SizedBox(height: 16),
                      
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      
                  
                      Row(
                        children: [
                          Obx(() => Checkbox(
                            value: _loginController.isRememberMe,
                            onChanged: (value) {
                              _loginController.toggleRememberMe(value);
                            },
                            activeColor: Theme.of(context).primaryColor,
                          )),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 8),
                  
                      ForgotPasswordWidget(
                        onForgotPasswordTap: () => _showForgotPasswordDialog(),
                      ),
                      SizedBox(height: 32),
                   
                     
                      Obx(() => CustomButton(
                        text: _loginController.isLoading.value ? 'Signing In...' : 'Sign In',
                        onPressed: _handleSignIn,
                        label: '',
                      )),
                      SizedBox(height: 24),
                      
                      OrDividerWidget(),
                      SizedBox(height: 24),
                      
                      GoogleSignInButton(
                        onPressed: () {
                          Get.snackbar(
                            'Info',
                            'Google Sign In functionality',
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                      ),
                      SizedBox(height: 32),
                      
                      // Sign up prompt
                      SignUpPromptWidget(
                        onSignUpTap: () => AppRouter.toSignup(),
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

  void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      await _loginController.login(email, password);
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController _forgotEmailController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _forgotEmailController,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: _loginController.isLoading.value 
              ? null 
              : () async {
                  if (_forgotEmailController.text.trim().isNotEmpty && 
                      GetUtils.isEmail(_forgotEmailController.text.trim())) {
                    await _loginController.forgotPassword(_forgotEmailController.text.trim());
                    Get.back();
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter a valid email address',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
            child: Text(_loginController.isLoading.value ? 'Sending...' : 'Send Reset Link'),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}