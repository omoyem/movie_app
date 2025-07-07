import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/models/base_response.dart';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:godly_seed_app/utils/helpers.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';
import 'package:godly_seed_app/view/login/models/forgot_password_request.dart';
import 'package:godly_seed_app/view/login/models/forgot_password_request.dart';
import 'package:godly_seed_app/view/login/models/login_request.dart';
import 'package:godly_seed_app/view/login/models/login_response.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_setup_screen.dart';
import 'package:godly_seed_app/view/sign_up/controller/signup_controller.dart';
import 'package:http/http.dart' as http;

import '../../../data/local/secure_storage_helper.dart';
import '../../../network/api_client.dart';
import '../../sign_up/screens/otp_verification_screen.dart';

class LoginController extends GetxController {
  
  SignupController get _signupController => Get.find<SignupController>();

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);

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

      LoginRequest request = LoginRequest(
        username: email,
        password: password
      );

      final response = await apiClient.postRequest(url: Endpoints.login, data: request.toJson());

      var loginResult = LoginResponse.fromJson(json.decode(response.body));

      if (loginResult.responseCode.toString() == "200") {
        logItem("login success");

        final responseMessage = loginResult.responseMessage ?? 'Login successful';
        
        if (loginResult.data != null) {
          try {
            var user = loginResult.data!;
            var token = loginResult.data!.accessToken;
            String userString = jsonEncode(user);
            logItem("about to save Ussesr and token");

            LocalStorageHelper localStorageHelper = LocalStorageHelper();
            await localStorageHelper.storeItem(key: "user", value: userString);
            await localStorageHelper.storeItem(key: "token", value: token!);

            logItem("Ussesr and token saved successsfully");

            if (loginResult.data?.accessToken != null) {
              _signupController.accessToken.value = loginResult.data!.accessToken!;
              await StorageService.saveAccessToken(loginResult.data!.accessToken!);
              
                logItem('Access token saved: ${loginResult.data?.accessToken!.substring(0, 20)}...');
            }

            // await StorageService.saveUser(_signupController.user.value!);
            // await StorageService.saveRememberMe(_signupController.isRememberMe.value);
            await StorageService.saveLoginStatus(true);

          } catch (e) {
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
        final profiles = loginResult.data?.profiles;
        if (profiles == null || (profiles.isEmpty)) {
          AppRouter.toProfileSetup();
        } else {
          // Pass profiles and email to profile selection
          Get.offAllNamed('/profileSelection', arguments: {
            'email': email,
            'profiles': profiles,
          });
        }
      } else {
        final errorMessage = loginResult.responseMessage ?? 'Login failed';

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

      ForgotPasswordRequest request = ForgotPasswordRequest(
          username: email
      );

      http.Response response = await apiClient.postRequest(url: Endpoints.forgotPassword, data: request.toJson());

      // if(response.body == null){
      //   showSnackBar(title: "Error", message: "Network Error. Kindly check your internet connection", type: 'error');
      //   return;
      // }

      logItem("I am jer again");
      logItem(response.body);
      var result = BaseResponse.fromJson(json.decode(response.body));
      logItem("hiiiiiiii helo");
      Get.back();

      if(result.responseCode == 200){
        final responseMessage = result.responseMessage ?? 'Password reset link sent successfully';

        await Future.delayed(Duration(milliseconds: 100), (){
          showSnackBar(title: "Success", message: responseMessage, type: "success");
        });

        await Future.delayed(Duration(milliseconds: 500), (){
          Get.to(() => OtpVerificationScreen(email: email), arguments: [{'type': 'forgot_password'}]);
        });


      } else {
        final responseMessage = result.responseMessage ?? 'Failed to send password reset link';

        showSnackBar(title: "Error", message: responseMessage, type: "error");
      }
    } catch (e) {

      logItem(e.toString());

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