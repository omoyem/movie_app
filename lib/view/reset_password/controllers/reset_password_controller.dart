import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_selection.dart';
import 'package:http/http.dart' as http show Client, Response;
import 'package:http/io_client.dart';
import 'package:godly_seed_app/utils/httpClient_helper.dart';

class ResetPasswordController extends GetxController {
  static const Duration _timeoutDuration = Duration(seconds: 30);

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRememberMe = false.obs;
  final RxString accessToken = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOtpSent = false.obs;
  final RxBool isOtpVerified = false.obs;

  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  http.Client? _httpClient;

  @override
  void onInit() {
    super.onInit();
    _initializeHttpClient();
  }

  @override
  void onClose() {
    _httpClient?.close();
    super.onClose();
  }

  void _initializeHttpClient() {
    if (kDebugMode) {
      _httpClient = IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
    } else {
      _httpClient = http.Client();
    }
  }

  void _handleNetworkError(dynamic error, String endpoint) {
    String errorMessage = 'Network error occurred';
    String technicalDetails = error.toString();
    
    if (error is HandshakeException) {
      if (error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
        errorMessage = kDebugMode 
          ? 'SSL Certificate verification failed. Check server certificate.'
          : 'Secure connection failed. Please contact support.';
        technicalDetails = 'SSL handshake failed: ${error.toString()}';
      } else {
        errorMessage = 'Secure connection failed. Please try again.';
        technicalDetails = 'SSL handshake error: ${error.toString()}';
      }
    } else if (error is SocketException) {
      if (error.osError?.errorCode == 7) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
        technicalDetails = 'DNS resolution failed';
      } else if (error.osError?.errorCode == 111) {
        errorMessage = 'Server is not responding. Please try again later.';
        technicalDetails = 'Connection refused';
      } else {
        errorMessage = 'Network connection failed. Please check your internet connection.';
      }
    } else if (error is HttpException) {
      errorMessage = 'Server error occurred. Please try again later.';
    } else if (error is FormatException) {
      errorMessage = 'Invalid response from server. Please try again.';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Request timed out. Please check your connection and try again.';
    }

    
    this.errorMessage.value = errorMessage;
    
    _logResponse(endpoint, 0, {}, error: technicalDetails);
    
    Get.snackbar(
      'Connection Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
    );
  }

  void _logResponse(String endpoint, int statusCode, Map<String, dynamic> responseBody, {String? error}) {
    final logMessage = '''
    ===========================================
    API Call: $endpoint
    Full URL: ${Endpoints.baseUrl}$endpoint
    Status Code: $statusCode
    Response: ${jsonEncode(responseBody)}
    ${error != null ? 'Error: $error' : ''}
    Timestamp: ${DateTime.now().toIso8601String()}
    Debug Mode: $kDebugMode
    ===========================================
    ''';
    
    if (kDebugMode) {
      print(logMessage);
    }
    
    developer.log(
      'API Response',
      name: 'SignupController', 
      error: error,
      stackTrace: error != null ? StackTrace.current : null,
    );
  }

  Future<http.Response> makeHttpRequest(
    String method,
    String endpoint,
    {Map<String, dynamic>? body,
    Map<String, String>? headers}
  ) async {
    final client = _httpClient ?? http.Client();
    final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
    
    try {
      if (kDebugMode) {
        print('Making $method request to: $uri');
        print('Using ${kDebugMode ? 'insecure' : 'secure'} HTTP client');
        if (body != null) print('Request body: ${jsonEncode(body)}');
      }

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'POST':
          if (headers != null && headers['Content-Type'] == 'application/json') {
            response = await client.post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(_timeoutDuration);
          } else {
            response = await client.post(
              uri,
              headers: headers,
              body: body?.map((key, value) => MapEntry(key, value.toString())),
            ).timeout(_timeoutDuration);
          }
          break;
        case 'GET':
          response = await client.get(uri, headers: headers).timeout(_timeoutDuration);
          break;
        case 'PUT':
          response = await client.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(_timeoutDuration);
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: headers).timeout(_timeoutDuration);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('HTTP Request failed: $e');
      }
      rethrow;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isOtpVerified.value = false;
      
      if (kDebugMode) {
        print('=== VERIFY OTP REQUEST ===');
        print('Email: $email');
        print('URL: ${Endpoints.baseUrl}${Endpoints.verifyOtp}');
      }

      final response = await makeHttpRequest(
        'POST',
        Endpoints.resetPassword,
        headers: {'Content-Type': 'application/json'},
        body: {
          'email': email,
          'password': passwordController.text,
        },
      );

      final responseBody = json.decode(response.body);
      _logResponse(Endpoints.resetPassword, response.statusCode, responseBody);

      bool isSuccess = false;
      if (response.statusCode == 200) {
        final responseCode = responseBody['response_code'];
        if (responseCode == 200 || responseCode == "200") {
          isSuccess = true;
          isOtpVerified.value = true;
        }
      }

      if (isSuccess) {
        if (kDebugMode) {
          print('✅ OTP verified successfully');
          print('Response: ${responseBody['response_message']}');
        }
        
        Get.snackbar(
          'Success',
          responseBody['response_message'] ?? 'OTP verified successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        if (kDebugMode) {
          print('❌ OTP verification failed');
          print('Response code: ${responseBody['response_code']}');
          print('Response message: ${responseBody['response_message']}');
        }
        
        errorMessage.value = responseBody['response_message'] ?? 'Invalid OTP';
        
        _logResponse(Endpoints.verifyOtp, response.statusCode, responseBody, 
          error: 'OTP verification failed: ${responseBody['response_message']}');
        
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in verifyOtp: $e');
      }
      _handleNetworkError(e, Endpoints.verifyOtp);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }


  void resetOtpStates() {
    isOtpSent.value = false;
    isOtpVerified.value = false;
    errorMessage.value = '';
  }

  void toggleRememberMe(bool? value) {
    isRememberMe.value = value ?? false;
    if (kDebugMode) {
      print('Remember Me toggled: ${isRememberMe.value}');
    }
  }

  Future<void> logout() async {
    try {
      if (kDebugMode) {
        print('=== LOGOUT ===');
        print('Current user: ${user.value?.email ?? 'No user'}');
      }
      
      user.value = null;
      accessToken.value = '';
      isRememberMe.value = false;
      errorMessage.value = '';
      resetOtpStates();

      await StorageService.clearUserData();

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed('/login'); 
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: ${e.toString()}');
      }
      
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Map<String, String> getAuthHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${accessToken.value}',
    };
    
    if (kDebugMode) {
      print('Auth headers: $headers');
    }
    
    return headers;
  }

  bool get isLoggedIn => user.value != null && accessToken.value.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;
  bool get canProceed => isOtpSent.value && isOtpVerified.value;


  void handleNetworkError(dynamic error, String endpoint) {
    _handleNetworkError(error, endpoint);
  }

  void logResponse(String endpoint, int statusCode, Map<String, dynamic> responseBody, {String? error}) {
    _logResponse(endpoint, statusCode, responseBody, error: error);
  }
}