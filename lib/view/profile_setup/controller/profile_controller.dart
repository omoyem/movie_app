import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/utils/httpClient_helper.dart';
import 'package:godly_seed_app/view/home/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';

import '../../bottom_nav/bottom_dart.dart';
import '../../login/models/login_response.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  final Rx<ProfileModel> profile = ProfileModel(type: ProfileType.kids).obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController screenTimeController = TextEditingController();

  final RxList<Profiles> userProfiles = <Profiles>[].obs;
  final RxString errorMessage = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isFormValid = false.obs;
  String? userEmail;
  String? _authToken;
  final LocalStorageHelper _storageHelper = LocalStorageHelper();

  http.Client? _httpClient;
  static const Duration _timeoutDuration = Duration(seconds: 30);
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _initializeHttpClient();
    _loadUserEmail();
    _loadAuthToken();
    _initializeForm();
    _setupValidation();

    // Always fetch profiles from server on profile selection screen
    if (Get.currentRoute.contains('profileSelection')) {
      fetchUserProfiles();
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    
    // Close HTTP client first
    _httpClient?.close();
    
    // Dispose controllers safely
    try {
      // nameController.dispose();
      // dateController.dispose();
      // screenTimeController.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Error disposing controllers: $e');
      }
    }
    
    super.onClose();
  }

  void _initializeHttpClient() {
    try {
      if (kDebugMode) {
        print('🔧 Initializing HTTP client in debug mode (allowing self-signed certificates)');
        _httpClient = IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
        print('DEBUG: Using INSECURE HTTP client (self-signed certificates allowed)');
      } else {
        print('🔧 Initializing HTTP client in release mode (strict SSL)');
        _httpClient = http.Client();
        print('DEBUG: Using SECURE HTTP client (strict SSL)');
      }
    } catch (e) {
      print('❌ Error initializing HTTP client: $e');
      _httpClient = http.Client();
    }
  }

  void _handleNetworkError(dynamic error, String endpoint) {
    if (_isDisposed) return;

    String errorMessage = 'Network error occurred';
    String technicalDetails = error.toString();

    if (error is HttpException) {
      if (error.message.contains('Authorization') ||
          error.message.contains('login again')) {
        errorMessage = 'Your session has expired. Please login again.';
        technicalDetails = 'Auth error: ${error.toString()}';

        _clearAuthData();
        
        // Navigate to login after clearing auth data
        Future.delayed(Duration(seconds: 2), () {
          if (!_isDisposed) {
            AppRouter.toLogin();
          }
        });
      } else {
        errorMessage = 'Server error occurred. Please try again later.';
      }
    } else if (error is HandshakeException) {
      print('DEBUG: HandshakeException caught: ${error.toString()}');
      if (error.toString().contains('CERTIFICATE_VERIFY_FAILED') || 
          error.toString().contains('self signed certificate')) {
        errorMessage = kDebugMode
            ? 'SSL Certificate verification failed. Using insecure connection for development.'
            : 'Secure connection failed. Please contact support.';
        technicalDetails = 'SSL handshake failed: ${error.toString()}';
        
        // Reinitialize HTTP client for SSL issues
        if (kDebugMode) {
          print('🔄 Reinitializing HTTP client due to SSL error...');
          _initializeHttpClient();
        }
      } else {
        errorMessage = 'Secure connection failed. Please try again.';
        technicalDetails = 'SSL handshake error: ${error.toString()}';
      }
    } else if (error is SocketException) {
      if (error.osError?.errorCode == 7) {
        errorMessage =
            'Cannot connect to server. Please check your internet connection.';
        technicalDetails = 'DNS resolution failed';
      } else if (error.osError?.errorCode == 111) {
        errorMessage = 'Server is not responding. Please try again later.';
        technicalDetails = 'Connection refused';
      } else {
        errorMessage =
            'Network connection failed. Please check your internet connection.';
      }
    } else if (error is FormatException) {
      errorMessage = 'Invalid response from server. Please try again.';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage =
          'Request timed out. Please check your connection and try again.';
    }

    this.errorMessage.value = errorMessage;

    _logResponse(endpoint, 0, {}, error: technicalDetails);

    if (!_isDisposed) {
      Get.snackbar(
        'Connection Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _storageHelper.deleteItem(key: 'auth_token');
      await _storageHelper.deleteItem(key: 'access_token');
      await _storageHelper.deleteItem(key: 'user_token');
      await StorageService.clearAll(); // Clear all auth data
      _authToken = null;
      print('🗑️ Auth data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }

  void _logResponse(String endpoint, int statusCode, Map<String, dynamic> responseBody, {String? error}) {
    final logMessage = '''
    ===========================================
    API Call: $endpoint
    Full URL: ${Endpoints.baseUrl}$endpoint
    Status Code: $statusCode
    Response: ${jsonEncode(responseBody)}
    ${error != null ? 'Error: $error' : ''}
    HTTP Client Type: ${kDebugMode ? 'Insecure (Development)' : 'Secure (Production)'}
    Timestamp: ${DateTime.now().toIso8601String()}
    Debug Mode: $kDebugMode
    ===========================================
    ''';

    if (kDebugMode) {
      print(logMessage);
    }
  }

  Future<http.Response> makeHttpRequest(String method, String endpoint,
      {Map<String, dynamic>? body,
      Map<String, String>? headers,
      bool requiresAuth = true}) async {
    if (_httpClient == null) {
      print('⚠️ HTTP client is null, reinitializing...');
      _initializeHttpClient();
    }

    if (requiresAuth && (_authToken == null || _authToken!.isEmpty)) {
      print('⚠️ Auth token required but not available, attempting to reload...');
      await _loadAuthToken(); // Make this async
      
      if (_authToken == null || _authToken!.isEmpty) {
        throw HttpException(
            'Authorization token not found. Please login again.');
      }
    }

    final client = _httpClient ?? http.Client();
    final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
    
    // Base headers
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth header if required and available
    if (requiresAuth && _authToken != null && _authToken!.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $_authToken';
    }

    // Add custom headers
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    try {
      if (kDebugMode) {
        print('🌐 Making $method request to: $uri');
        print('🔧 Using ${kDebugMode ? 'insecure' : 'secure'} HTTP client');
        print('🔐 Auth required: $requiresAuth');
        print(
            '🔐 Token available: ${_authToken != null && _authToken!.isNotEmpty}');
        print('📋 Headers: ${requestHeaders.keys.join(', ')}');
        if (_authToken != null) {
          print(
              '🔐 Auth header: Authorization: Bearer ${_authToken!.substring(0, math.min(10, _authToken!.length))}...');
        }
        if (body != null) print('📤 Request body: ${jsonEncode(body)}');
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await client
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeoutDuration);
          break;
        case 'GET':
          response = await client
              .get(uri, headers: requestHeaders)
              .timeout(_timeoutDuration);
          break;
        case 'PUT':
          response = await client
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(_timeoutDuration);
          break;
        case 'DELETE':
          response = await client
              .delete(uri, headers: requestHeaders)
              .timeout(_timeoutDuration);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response headers: ${response.headers}');
        print('📥 Response body: ${response.body}');
      }

      // Handle unauthorized responses
      if (response.statusCode == 401) {
        print('🚫 Unauthorized (401) - Token may be expired or invalid');
        throw HttpException('Authorization failed. Please login again.');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HTTP Request failed: $e');
        print('🔍 Error type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  void _loadUserEmail() async {
    final args = Get.arguments;
    if (args != null && args is Map && args['email'] != null) {
      userEmail = args['email'];
      if (kDebugMode)
        print(
            'ProfileController: Loaded userEmail from Get.arguments: $userEmail');
      await _storageHelper.storeItem(key: 'user_email', value: userEmail!);
    } else {
      // Try to get from stored user data
      final user = await StorageService.getUser();
      if (user != null && user.email.isNotEmpty) {
        userEmail = user.email;
        if (kDebugMode)
          print(
              'ProfileController: Loaded userEmail from StorageService.getUser(): $userEmail');
        await _storageHelper.storeItem(key: 'user_email', value: userEmail!);
      } else {
        userEmail = await _storageHelper.retrieveItem(key: 'user_email');
        if (kDebugMode)
          print(
              'ProfileController: Loaded userEmail from LocalStorageHelper: $userEmail');
      }
    }

    if (userEmail == null || userEmail!.isEmpty) {
      print('⚠️ Warning: User email not found in storage or arguments');
    } else {
      print('✅ User email loaded: $userEmail');
    }
  }

  // Make this method async and improve token loading
  Future<void> _loadAuthToken() async {
    try {
      final args = Get.arguments;
      
      // First, try to get from navigation arguments
      if (args != null && args is Map && args['token'] != null) {
        _authToken = args['token'];
        await StorageService.saveAccessToken(_authToken!);
        print('✅ Auth token loaded from arguments and saved');
        return;
      }

      // Then try to get from StorageService
      _authToken = await StorageService.getAccessToken();
      if (_authToken != null && _authToken!.isNotEmpty) {
        print('✅ Auth token loaded from StorageService');
        return;
      }

  
      _authToken = await _storageHelper.retrieveItem(key: 'auth_token');
      if (_authToken != null && _authToken!.isNotEmpty) {
        print('✅ Auth token loaded from secure storage');
        return;
      }

      _authToken = await _storageHelper.retrieveItem(key: 'access_token');
      if (_authToken != null && _authToken!.isNotEmpty) {
        print('✅ Auth token loaded from secure storage (access_token key)');
        return;
      }

      print('⚠️ Warning: Auth token not found in any storage');
    } catch (e) {
      print('❌ Error loading auth token: $e');
    }
  }

  void setAuthToken(String token) async {
    _authToken = token;
    await StorageService.saveAccessToken(token);
    await _storageHelper.storeItem(key: 'auth_token', value: token);
    print('✅ Auth token set manually and saved to both storage systems');
  }

  void _initializeForm() {
    // Check if disposed before accessing controllers
    if (_isDisposed) return;
    
    if (profile.value.type == ProfileType.kids) {
      nameController.text = 'Name'; 
      screenTimeController.text = '3pm - 7pm';
    } else {
      nameController.text = 'Name';
      nameController.text = 'Name';
    }
    updateName(nameController.text);
    updateScreenTime(screenTimeController.text);
  }

  void _setupValidation() {
    ever(profile, (_) => _validateForm());
  }

  void _validateForm() {
    if (_isDisposed) return;
    
    final name = profile.value.name.trim();

    if (profile.value.type == ProfileType.kids) {
      isFormValid.value = name.isNotEmpty &&
          profile.value.dateOfBirth != null &&
          profile.value.gender != null &&
          profile.value.screenTime != null &&
          profile.value.screenTime!.isNotEmpty;
    } else {
      isFormValid.value = name.isNotEmpty;
    }
  }

  Future<void> fetchUserProfiles({int retryCount = 0}) async {
    print('DEBUG: fetchUserProfiles called');
    if (_isDisposed) return;

   
    if (userEmail == null || userEmail!.isEmpty) {
       _loadUserEmail();
    }

    if (userEmail == null || userEmail!.isEmpty) {
      print('DEBUG: User email still missing after _loadUserEmail');
      errorMessage.value = 'User not found. Please login again.';
      return;
    }
    if (_authToken == null || _authToken!.isEmpty) {
      await _loadAuthToken();
    }

    if (_authToken == null || _authToken!.isEmpty) {
      print('DEBUG: Auth token still missing after _loadAuthToken');
      errorMessage.value = 'Authorization token not found. Please login again.';
      _handleNetworkError(HttpException('Authorization token not found. Please login again.'), Endpoints.profileSelection);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print('=== FETCH USER PROFILES (Attempt ${retryCount + 1}) ===');
        print('User email: $userEmail');
        print('Auth token available: ${_authToken != null && _authToken!.isNotEmpty}');
        print('URL: ${Endpoints.baseUrl}${Endpoints.profileSelection}');
      }
      final requestBody = {
        'user_id': userEmail!,
      };

      final response = await makeHttpRequest(
        'POST',
        Endpoints.profileSelection,
        body: requestBody,
        requiresAuth: true, 
      );

      final responseBody = json.decode(response.body);
      _logResponse(Endpoints.profileSelection, response.statusCode, responseBody);

      if (response.statusCode == 200) {
        final profileResponse = ProfileResponse.fromJson(responseBody);
        print('DEBUG: Parsed profileResponse: responseCode=${profileResponse.responseCode}, message=${profileResponse.responseMessage}, profiles=${profileResponse.data.length}');

        if (profileResponse.responseCode == 200) {
          userProfiles.value = profileResponse.data;
          print('DEBUG: userProfiles updated, count=${userProfiles.length}');
          if (kDebugMode) {
            print('✅ Successfully loaded ${userProfiles.length} profiles');
          }

          // Save profiles to storage
          if (responseBody['data'] != null) {
            final profiles = responseBody['data'];
            await StorageService.saveProfiles(profiles);
          }
        } else if (profileResponse.responseMessage != null && profileResponse.responseMessage.toLowerCase().contains('no profile found')) {

          userProfiles.clear();
          isLoading.value = false;
          print('DEBUG: No profiles found. Stopping loading.');
          return;
        } else {
          errorMessage.value = profileResponse.responseMessage;
          print('DEBUG: API returned error: ${profileResponse.responseMessage}');
          if (kDebugMode) {
            print('❌ API returned error: ${profileResponse.responseMessage}');
          }
        }
      } else {
        print('DEBUG: Server returned status ${response.statusCode}');
        throw HttpException('Server returned ${response.statusCode}');
      }

    } catch (e) {
      print('DEBUG: Exception in fetchUserProfiles: $e');
      if (kDebugMode) {
        print('❌ Exception in fetchUserProfiles: $e');
      }
      
      if (e is HandshakeException && kDebugMode && retryCount < 2) {
        print('🔄 Retrying due to SSL handshake error... (${retryCount + 1}/3)');
        _initializeHttpClient(); 
        await Future.delayed(Duration(seconds: 1));
        return fetchUserProfiles(retryCount: retryCount + 1);
      }
      
      _handleNetworkError(e, Endpoints.profileSelection);
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  Future<void> saveProfile({int retryCount = 0}) async {
    print('DEBUG: saveProfile called');
    if (_isDisposed) return;

    if (!isFormValid.value) {
      print('DEBUG: Form is not valid. Fields: name="${profile.value.name}", dob="${profile.value.dateOfBirth}", gender="${profile.value.gender}", screenTime="${profile.value.screenTime}"');
      if (!_isDisposed) {
        Get.snackbar(
          'Validation Error',
          'Please fill in all required fields correctly',
          backgroundColor: primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
      return;
    }

    if (userEmail == null || userEmail!.isEmpty) {
      print('DEBUG: User email is missing');
      if (!_isDisposed) {
        Get.snackbar(
          'Error',
          'User email not found. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
      return;
    }

    // Ensure we have auth token
    if (_authToken == null || _authToken!.isEmpty) {
      await _loadAuthToken();
    }

    if (_authToken == null || _authToken!.isEmpty) {
      print('DEBUG: Auth token missing for saveProfile');
      if (!_isDisposed) {
        Get.snackbar(
          'Error',
          'Authorization token not found. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final requestBody = {
        "user_id": userEmail!,
        "name": profile.value.name,
        "gender": profile.value.gender?.toString().split('.').last ?? "Male", 
        "screen_time": profile.value.screenTime ?? "3pm-6pm",
        "dob": profile.value.dateOfBirth!.toIso8601String().split('T')[0],
      };

      if (kDebugMode) {
        print('=== SAVE PROFILE (Attempt ${retryCount + 1}) ===');
        print('User email: $userEmail');
        print('Auth token available: ${_authToken != null && _authToken!.isNotEmpty}');
        print('Request body: $requestBody');
        print('URL: ${Endpoints.baseUrl}${Endpoints.profileSetup}');
      }

      final response = await makeHttpRequest(
        'POST',
        Endpoints.profileSetup,
        body: requestBody,
        requiresAuth: true, 
      );

      final responseBody = json.decode(response.body);
      _logResponse(Endpoints.profileSetup, response.statusCode, responseBody);
      final responseBody = json.decode(response.body);
      _logResponse(Endpoints.profileSetup, response.statusCode, responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {

        bool isSuccess = false;
        String successMessage = 'Profile created successfully!';
        
        if (responseBody != null) {
          
          final responseCode = responseBody['response_code'];
          final responseMessage = responseBody['response_message'];
          
      
          if (responseCode == 200 || responseCode == 201 || 
              (responseMessage != null && responseMessage.toString().toLowerCase().contains('success')) ||
              responseCode == null) {
            isSuccess = true;
            successMessage = responseMessage ?? successMessage;
          }
        } else {
   
          isSuccess = true;
        }

        if (isSuccess) {
          await _saveToStorage();

          if (kDebugMode) {
            print('✅ Profile saved successfully');
            print('Success message: $successMessage');
          }
          if (kDebugMode) {
            print('✅ Profile saved successfully');
            print('Success message: $successMessage');
          }

          if (!_isDisposed) { 
            Get.snackbar(
              'Success',
              successMessage,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );

            await StorageService.saveUserProfile(requestBody);
            
     
            Get.offAllNamed('/profileSelection', arguments: {'profile_id': profile});
          }
        } else {
          // Server returned error message
          String errorMsg = responseBody?['response_message'] ?? 'Failed to create profile';
          throw HttpException(errorMsg);
        }
      } else {
        // Non-success status code
        String errorMsg = 'Server returned status ${response.statusCode}';
        if (responseBody != null && responseBody['response_message'] != null) {
          errorMsg = responseBody['response_message'];
        }
        throw HttpException(errorMsg);
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in saveProfile: $e');
      }
      
      if (e is HandshakeException && kDebugMode && retryCount < 2) {
        print('🔄 Retrying due to SSL handshake error... (${retryCount + 1}/3)');
        _initializeHttpClient(); 
        await Future.delayed(Duration(seconds: 1));
        return saveProfile(retryCount: retryCount + 1);
      }
      
      _handleNetworkError(e, Endpoints.profileSetup);
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  void selectProfileType(ProfileType type) {
    if (_isDisposed) return;
    profile.value = profile.value.copyWith(type: type);
    _initializeForm();
  }

  void updateName(String name) {
    if (_isDisposed) return;
    profile.value = profile.value.copyWith(name: name);
    _validateForm();
  }

  void updateEmail(String email) {
    if (_isDisposed) return;
    _validateForm();
  }

  void selectGender(Gender gender) {
    if (_isDisposed) return;
    profile.value = profile.value.copyWith(gender: gender);
    _validateForm();
  }

  void updateScreenTime(String screenTime) {
    if (_isDisposed) return;
    profile.value = profile.value.copyWith(screenTime: screenTime);
    _validateForm();
  }

  void selectDateOfBirth(DateTime date) {
    if (_isDisposed) return;
    profile.value = profile.value.copyWith(dateOfBirth: date);
    
    // Safely update controller if not disposed
    if (!_isDisposed) {
      dateController.text = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    }
    _validateForm();
  }

  // Check if user can add more profiles (max 5)
  bool get canAddMoreProfiles => userProfiles.length < 5;

  void navigateToProfileSetup() {
    if (_isDisposed) return;
    AppRouter.toProfileSetup();
  }

  void selectProfile(UserProfile selectedProfile) {
    if (_isDisposed) return;
    
    Get.snackbar(
      'Profile Selected',
      'Switched to ${selectedProfile.name} profile',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Get.offAllNamed('/home', arguments: {'profile_id': selectedProfile.id});
  }

  Future<void> refreshProfiles() async {
    if (_isDisposed) return;
    await fetchUserProfiles();
  }

  Future<void> _saveToStorage() async {
    if (_isDisposed) return;
    
    final profileData = {
      'type': profile.value.type.toString(),
      'name': profile.value.name,
      'email': userEmail,
      'dateOfBirth': profile.value.dateOfBirth?.toIso8601String(),
      'gender': profile.value.gender?.toString(),
      'screenTime': profile.value.screenTime,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (kDebugMode) {
      print('💾 Saving profile locally: $profileData');
    }

    try {
      await _storageHelper.storeItem(
          key: 'latest_profile', value: profileData.toString());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving to local storage: $e');
      }
    }
  }

  void resetForm() {
    if (_isDisposed) return;
    
    profile.value = ProfileModel(type: ProfileType.kids);
    
    // Safely clear controllers if not disposed
    if (!_isDisposed) {
      nameController.clear();
      dateController.clear();
      screenTimeController.clear();
    }
    
    _initializeForm();
  }

  Future<void> loadAuthTokenAndFetchProfiles() async {
    if (_isDisposed) return;
    await _loadAuthToken();
    await fetchUserProfiles();
  }
}