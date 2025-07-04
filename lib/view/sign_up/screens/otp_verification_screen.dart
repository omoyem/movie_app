import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/view/sign_up/controller/signup_controller.dart';
import 'package:godly_seed_app/view/sign_up/screens/signup_screen.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';
import 'package:godly_seed_app/view/widgets/background_widget.dart';
import 'package:godly_seed_app/view/widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final SignupController _signupController = Get.find<SignupController>();
  
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
                          'VERIFY CODE',
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
                              TextSpan(text: 'We\'ve sent a 6-digit code to\n'),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) => _buildOtpField(index)),
                        ),
                        SizedBox(height: 20),
                        
                        // Timer
                        if (!_canResend)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.orange.shade600,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Code expires in $_formattedTime',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 40),
                        
                      
                        Obx(() => CustomButton(
                          text: _signupController.isLoading.value 
                              ? 'Verifying...' 
                              : 'Verify Code',
                          onPressed: 
                              
                          _handleVerifyOtp,
                          label: '',
                        )),
                        SizedBox(height: 24),
                        
                        
                        TextButton(
                          onPressed: _canResend ? _handleResendCode : null,
                          child: Text(
                            _canResend ? 'Resend Code' : 'Resend Code ($_formattedTime)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _canResend ? Colors.blue.shade600 : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        
                        // Help Text
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Didn\'t receive the code?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Check your spam/junk folder\n• Make sure the email address is correct\n• Wait a few minutes and try again',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildOtpField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty 
              ? Colors.blue.shade300 
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        onTap: () {
          if (_otpControllers[index].text.isNotEmpty) {
            _otpControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _otpControllers[index].text.length),
            );
          }
        },
      ),
    );
  }

  void _handleVerifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      Get.snackbar(
        'Invalid Code',
        'Please enter the complete 6-digit code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    final success = await _signupController.verifyOtp(widget.email, otp);
    
    if (success) {
     Get.off(
          () => SignupScreen(),
          arguments: {'email': widget.email}
        );
    }
  }

  void _handleResendCode() async {
    final success = await _signupController.sendOtp(widget.email);
    
    if (success) {
    
      for (var controller in _otpControllers) {
        controller.clear();
      }
     
      _focusNodes[0].requestFocus();

      _timer?.cancel();
      _startTimer();
      
      Get.snackbar(
        'Code Sent',
        'A new verification code has been sent to your email',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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