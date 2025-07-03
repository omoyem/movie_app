import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_setup_screen.dart';
import 'package:godly_seed_app/view/sign_up/controller/signup_controller.dart';

class LoginController extends GetxController {
  
  SignupController get _signupController => Get.find<SignupController>();

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
   
    if (!Get.isRegistered<SignupController>()) {
      Get.put(SignupController());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      
      if (kDebugMode) {
        print('=== LOGIN REQUEST ===');
        print('Email: $email');
        print('URL: ${Endpoints.baseUrl}${Endpoints.login}');
      }

      final response = await _signupController.makeHttpRequest(
        'POST',
        Endpoints.login,
        body: {
          'username': email,
          'password': password,
        },
      );

      final responseBody = json.decode(response.body);
      _signupController.logResponse(Endpoints.login, response.statusCode, responseBody);

      if (response.statusCode == 200 && responseBody['response_code'] == "200") {
        final responseMessage = responseBody['response_message'] ?? 'Login successful';
        
        if (responseBody['data'] != null) {
          try {
            final userData = responseBody['data'];
            _signupController.user.value = User.fromJson(userData);
            
            if (userData['access_token'] != null) {
              _signupController.accessToken.value = userData['access_token'];
              await StorageService.saveAccessToken(userData['access_token']);
              
              if (kDebugMode) {
                print('Access token saved: ${userData['access_token'].substring(0, 20)}...');
              }
            }

            await StorageService.saveUser(_signupController.user.value!);
            await StorageService.saveRememberMe(_signupController.isRememberMe.value);
            await StorageService.saveLoginStatus(true);

          } catch (e) {
            _signupController.logResponse(Endpoints.login, response.statusCode, responseBody, 
              error: 'User data parsing failed: ${e.toString()}');
            
            Get.snackbar(
              'Error',
              'Failed to parse user data: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        }

        Get.snackbar(
          'Success',
          responseMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Check if user has created profile
        final userProfile = await StorageService.getUserProfile();
        if (userProfile == null) {
          
          AppRouter.toProfileSetup(); 
        } else {
         
          AppRouter.toProfile(); 
        }
      } else {
        final errorMessage = responseBody['response_message'] ?? 'Login failed';
        _signupController.logResponse(Endpoints.login, response.statusCode, responseBody, 
          error: 'Login failed: $errorMessage');
        
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _signupController.handleNetworkError(e, Endpoints.login);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      
      if (kDebugMode) {
        print('=== FORGOT PASSWORD REQUEST ===');
        print('Email: $email');
        print('URL: ${Endpoints.baseUrl}${Endpoints.forgotPassword}');
      }

      final response = await _signupController.makeHttpRequest(
        'POST',
        Endpoints.forgotPassword,
        body: {
          'email': email,
        },
      );

      final responseBody = json.decode(response.body);
      _signupController.logResponse(Endpoints.forgotPassword, response.statusCode, responseBody);

      if (response.statusCode == 200 && responseBody['response_code'] == "200") {
        final responseMessage = responseBody['response_message'] ?? 'Password reset link sent successfully';
        
        Get.snackbar(
          'Success',
          responseMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        
      } else {
        final errorMessage = responseBody['response_message'] ?? 'Failed to send password reset link';
        _signupController.logResponse(Endpoints.forgotPassword, response.statusCode, responseBody, 
          error: 'Forgot password failed: $errorMessage');
        
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _signupController.handleNetworkError(e, Endpoints.forgotPassword);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRememberMe(bool? value) {
    _signupController.toggleRememberMe(value);
  }

  
  Future<void> autoLogin() async {
   try {
      final isRemembered = await StorageService.getRememberMe();
      final isLoggedIn = await StorageService.getLoginStatus();
      final savedUser = await StorageService.getUser();
      final savedToken = await StorageService.getAccessToken();

      if (isRemembered && isLoggedIn && savedUser != null && savedToken != null) {
        _signupController.user.value = savedUser;
        _signupController.accessToken.value = savedToken;
        _signupController.isRememberMe.value = true;
        
        if (kDebugMode) {
          print('Auto-login successful for user: ${savedUser.email}');
        }
        
        Get.offAll(() => ProfileSetupScreen());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auto-login failed: ${e.toString()}');
      }
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      _signupController.user.value = null;
      _signupController.accessToken.value = '';
      _signupController.isRememberMe.value = false;
      
      if (kDebugMode) {
        print('Logout successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: ${e.toString()}');
      }
    }
  }

  bool get isRememberMe => _signupController.isRememberMe.value;
  bool get isLoggedIn => _signupController.isLoggedIn;
  User? get user => _signupController.user.value;
}