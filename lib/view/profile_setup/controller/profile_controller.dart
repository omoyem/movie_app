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
import 'package:godly_seed_app/view/bottom_nav/bottom_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';
import '../model/profile_response.dart';

class ProfileController extends GetxController {
  final Rx<UserProfile> profile = UserProfile(ageGroup: ProfileType.kids.toString()).obs;

  final RxList<UserProfile> userProfiles = <UserProfile>[].obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFormValid = false.obs;
  String? userEmail;
  String? _authToken;
  final LocalStorageHelper _storageHelper = LocalStorageHelper();

  http.Client? _httpClient;
  bool _isClientClosed = false;
  static const Duration _timeoutDuration = Duration(seconds: 30);
  static const int _maxRetries = 3;

  @override
  void onInit() {
    super.onInit();
    _initializeHttpClient();
    _loadUserEmail();
    _loadAuthToken();
    _initializeForm();
    _setupValidation();

    if (Get.currentRoute.contains('profileSelection')) {
      fetchUserProfiles();
    }
  }

  @override
  void onClose() {
    _safeCloseHttpClient();

    super.onClose();
  }

  void _initializeHttpClient() {
    try {
      _safeCloseHttpClient();

      Future.delayed(Duration(milliseconds: 100), () {
        if (kDebugMode) {
          print(
              '🔧 Initializing HTTP client in debug mode (allowing self-signed certificates)');
          _httpClient =
              IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
          print(
              'DEBUG: Using INSECURE HTTP client (self-signed certificates allowed)');
        } else {
          print('🔧 Initializing HTTP client in release mode (strict SSL)');
          _httpClient = http.Client();
          print('DEBUG: Using SECURE HTTP client (strict SSL)');
        }

        _isClientClosed = false;
      });
    } catch (e) {
      print('❌ Error initializing HTTP client: $e');
      _httpClient = http.Client();
      _isClientClosed = false;
    }
  }

  void _safeCloseHttpClient() {
    if (_httpClient != null && !_isClientClosed) {
      try {
        _httpClient!.close();
        print('🔒 HTTP client closed safely');
      } catch (e) {
        print('⚠️ Error closing HTTP client: $e');
      }
    }
    _isClientClosed = true;
    _httpClient = null;
  }

  http.Client _getOrCreateHttpClient() {
    if (_httpClient == null || _isClientClosed) {
      print('🔄 Creating new HTTP client (existing was null or closed)');

      if (kDebugMode) {
        _httpClient =
            IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
      } else {
        _httpClient = http.Client();
      }
      _isClientClosed = false;
    }
    return _httpClient!;
  }

  void _handleNetworkError(dynamic error, String endpoint) {
    String errorMessage = 'Network error occurred';
    String technicalDetails = error.toString();

    if (error is HttpException) {
      if (error.message.contains('Authorization') ||
          error.message.contains('login again')) {
        errorMessage = 'Your session has expired. Please login again.';
        technicalDetails = 'Auth error: ${error.toString()}';

        _clearAuthData();

        Future.delayed(Duration(seconds: 2), () {
          AppRouter.toLogin();
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

        if (kDebugMode) {
          print('🔄 Reinitializing HTTP client due to SSL error...');
          _initializeHttpClient();
        }
      } else {
        errorMessage = 'Secure connection failed. Please try again.';
        technicalDetails = 'SSL handshake error: ${error.toString()}';
      }
    } else if (error is SocketException) {
      if (error.toString().contains('Connection attempt cancelled')) {
        errorMessage = 'Connection was cancelled. Please try again.';
        technicalDetails = 'Connection cancelled: ${error.toString()}';

        _initializeHttpClient();
      } else if (error.osError?.errorCode == 7) {
        errorMessage = 'Cannot connect to server. Please check your internet connection and try again.';
        technicalDetails = 'DNS resolution failed - hostname not found';
        
       
        Get.snackbar(
          'Connection Error',
          'Unable to reach the server. Please check your internet connection.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 8),
          mainButton: TextButton(
            onPressed: () {
              // Retry the operation
              if (endpoint == Endpoints.profileSetup) {
                saveProfile();
              } else if (endpoint == Endpoints.profileSelection) {
                fetchUserProfiles();
              }
            },
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        );
        return;
      } else if (error.osError?.errorCode == 111) {
        errorMessage = 'Server is not responding. Please try again later.';
        technicalDetails = 'Connection refused';
      } else {
        errorMessage = 'Network connection failed. Please check your internet connection.';
      }
    } else if (error is FormatException) {
      errorMessage = 'Invalid response from server. Please try again.';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage = 'Request timed out. Please check your connection and try again.';
    } else if (error.toString().contains('Client is already closed')) {
      errorMessage = 'Connection was interrupted. Please try again.';
      technicalDetails = 'HTTP client was closed prematurely';

      _initializeHttpClient();
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

  Future<void> _clearAuthData() async {
    try {
      await _storageHelper.deleteItem(key: 'auth_token');
      await _storageHelper.deleteItem(key: 'access_token');
      await _storageHelper.deleteItem(key: 'user_token');
      await StorageService.clearAll();
      _authToken = null;
      print('🗑️ Auth data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }

  void _logResponse(
      String endpoint, int statusCode, Map<String, dynamic> responseBody,
      {String? error}) {
    final logMessage = '''
    ===========================================
    API Call: $endpoint
    Full URL: ${Endpoints.baseUrl}$endpoint
    Status Code: $statusCode
    Response: ${jsonEncode(responseBody)}
    ${error != null ? 'Error: $error' : ''}
    HTTP Client Type: ${kDebugMode ? 'Insecure (Development)' : 'Secure (Production)'}
    Client State: ${_isClientClosed ? 'Closed' : 'Open'}
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
      bool requiresAuth = true,
      int retryCount = 0}) async {
    if (requiresAuth && (_authToken == null || _authToken!.isEmpty)) {
      print(
          '⚠️ Auth token required but not available, attempting to reload...');
      await _loadAuthToken();

      if (_authToken == null || _authToken!.isEmpty) {
        throw HttpException(
            'Authorization token not found. Please login again.');
      }
    }

    final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _authToken != null && _authToken!.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $_authToken';
    }

    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      http.Client? client;

      try {
        client = _getOrCreateHttpClient();

        if (kDebugMode) {
          print(
              '🌐 Making $method request to: $uri (Attempt ${attempt + 1}/${_maxRetries + 1})');
          print('🔧 Using ${kDebugMode ? 'insecure' : 'secure'} HTTP client');
          print('🔧 Client state: ${_isClientClosed ? 'Closed' : 'Open'}');
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

        if (response.statusCode == 401) {
          print('🚫 Unauthorized (401) - Token may be expired or invalid');
          throw HttpException('Authorization failed. Please login again.');
        }

        return response;
      } catch (e) {
        if (kDebugMode) {
          print('❌ HTTP Request failed (attempt ${attempt + 1}): $e');
          print('🔍 Error type: ${e.runtimeType}');
        }

        bool shouldRetry = false;

        if (e is SocketException) {
          if (e.toString().contains('Connection attempt cancelled') ||
              e.toString().contains('Connection refused') ||
              e.toString().contains('Connection reset')) {
            shouldRetry = true;
          }
        } else if (e.toString().contains('Client is already closed') ||
            e.toString().contains('TimeoutException') ||
            e is HandshakeException) {
          shouldRetry = true;
        }

        if (shouldRetry && attempt < _maxRetries) {
          print(
              '🔄 Retrying request (attempt ${attempt + 2}/${_maxRetries + 1})...');

          
          _safeCloseHttpClient();
          await Future.delayed(
              Duration(milliseconds: 500 * (attempt + 1))); 
          _initializeHttpClient();
          await Future.delayed(
              Duration(milliseconds: 100));

          continue;
        }

        rethrow;
      }
    }

    throw HttpException('Maximum retry attempts exceeded');
  }

  void _loadUserEmail() async {
    final args = Get.arguments;
    if (args != null && args is Map && args['email'] != null) {
      userEmail = args['email'];
      if (kDebugMode) {
        print(
            'ProfileController: Loaded userEmail from Get.arguments: $userEmail');
      }
      await _storageHelper.storeItem(key: 'user_email', value: userEmail!);
    } else {
      final user = await StorageService.getUser();
      if (user != null && user.email.isNotEmpty) {
        userEmail = user.email;
        if (kDebugMode) {
          print(
              'ProfileController: Loaded userEmail from StorageService.getUser(): $userEmail');
        }
        await _storageHelper.storeItem(key: 'user_email', value: userEmail!);
      } else {
        userEmail = await _storageHelper.retrieveItem(key: 'user_email');
        if (kDebugMode) {
          print(
              'ProfileController: Loaded userEmail from LocalStorageHelper: $userEmail');
        }
      }
    }

    if (userEmail == null || userEmail!.isEmpty) {
      print('⚠️ Warning: User email not found in storage or arguments');
    } else {
      print('✅ User email loaded: $userEmail');
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      final args = Get.arguments;

      if (args != null && args is Map && args['token'] != null) {
        _authToken = args['token'];
        await StorageService.saveAccessToken(_authToken!);
        print('✅ Auth token loaded from arguments and saved');
        return;
      }

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
    if (profile.value.ageGroup == ProfileType.kids.toString()) {
    } else {
     
    }
    if(profile.value.name != null) {
      updateName(profile.value.name!);
      updateScreenTime(profile.value.screenTime ?? '');
    }
  }

  void _setupValidation() {
    ever(profile, (_) => _validateForm());
  }

  void _validateForm() {
    final name = profile.value.name!.trim();

    if (profile.value.ageGroup == ProfileType.kids.toString()) {
      isFormValid.value = name.isNotEmpty &&
          profile.value.dob != null &&
          profile.value.gender != null &&
          profile.value.screenTime != null &&
          profile.value.screenTime!.isNotEmpty;
    } else {
      isFormValid.value = name.isNotEmpty;
    }
  }

  Future<void> fetchUserProfiles({int retryCount = 0}) async {
    print('DEBUG: fetchUserProfiles called');

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
      _handleNetworkError(
          HttpException('Authorization token not found. Please login again.'),
          Endpoints.profileSelection);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print('=== FETCH USER PROFILES ===');
        print('User email: $userEmail');
        print(
            'Auth token available: ${_authToken != null && _authToken!.isNotEmpty}');
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
      _logResponse(
          Endpoints.profileSelection, response.statusCode, responseBody);

      if (response.statusCode == 200) {
        final profileResponse = ProfileResponse.fromJson(responseBody);

        if (profileResponse.responseCode == 200) {
          userProfiles.value = profileResponse.data!;
          print('DEBUG: userProfiles updated, count=${userProfiles.length}');
          if (kDebugMode) {
            print('✅ Successfully loaded ${userProfiles.length} profiles');
          }

          if (responseBody['data'] != null) {
            final profiles = responseBody['data'];
            await StorageService.saveProfiles(profiles);
          }
        } else if (profileResponse.responseMessage != null &&
            profileResponse.responseMessage!
                .toLowerCase()
                .contains('no profile found')) {
          userProfiles.clear();
          print('DEBUG: No profiles found.');
        } else {
          errorMessage.value = profileResponse.responseMessage!;
          print(
              'DEBUG: API returned error: ${profileResponse.responseMessage}');
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

      _handleNetworkError(e, Endpoints.profileSelection);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile() async {
    print('DEBUG: saveProfile called');

    if (!isFormValid.value) {
      print(
          'DEBUG: Form is not valid. Fields: name="${profile.value.name}", dob="${profile.value.dob}", gender="${profile.value.gender}", screenTime="${profile.value.screenTime}"');
      Get.snackbar(
        'Validation Error',
        'Please fill in all required fields correctly',
        backgroundColor: primaryColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (userEmail == null || userEmail!.isEmpty) {
      print('DEBUG: User email is missing');
      Get.snackbar(
        'Error',
        'User email not found. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_authToken == null || _authToken!.isEmpty) {
      await _loadAuthToken();
    }

    if (_authToken == null || _authToken!.isEmpty) {
      print('DEBUG: Auth token missing for saveProfile');
      Get.snackbar(
        'Error',
        'Authorization token not found. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final requestBody = {
        "user_id": userEmail!,
        "name": profile.value.name,
        "gender": profile.value.gender?.toString().split('.').last ?? "Male",
        "screen_time": profile.value.screenTime ?? "3pm-6pm",
        "dob": profile.value.dob,
      };

      if (kDebugMode) {
        print('=== SAVE PROFILE ===');
        print('User email: $userEmail');
        print(
            'Auth token available: ${_authToken != null && _authToken!.isNotEmpty}');
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        bool isSuccess = false;
        String successMessage = 'Profile created successfully!';

        if (responseBody != null) {
          final responseCode = responseBody['response_code'];
          final responseMessage = responseBody['response_message'];

          if (responseCode == 200 ||
              responseCode == 201 ||
              (responseMessage != null &&
                  responseMessage
                      .toString()
                      .toLowerCase()
                      .contains('success')) ||
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

          Get.snackbar(
            'Success',
            successMessage,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );

          await StorageService.saveUserProfile(requestBody);

          await Future.delayed(Duration(milliseconds: 500));
          _initializeHttpClient();

          Get.offAllNamed('/profileSelection', arguments: {
            'profile_id': profile.value,
            'email': userEmail,
            'token': _authToken,
          });
        } else {
          String errorMsg =
              responseBody?['response_message'] ?? 'Failed to create profile';
          throw HttpException(errorMsg);
        }
      } else {
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

      _handleNetworkError(e, Endpoints.profileSetup);
    } finally {
      isLoading.value = false;
    }
  }

  void selectProfileType(ProfileType type) {
    profile.value = profile.value.copyWith(ageGroup: type.toString());
    _initializeForm();
  }

  void updateName(String name) {
    profile.value = profile.value.copyWith(name: name);
    _validateForm();
  }

  void updateEmail(String email) {
    _validateForm();
  }

  void selectGender(Gender gender) {
    profile.value = profile.value.copyWith(gender: gender.toString());
    _validateForm();
  }

  void updateScreenTime(String screenTime) {
    profile.value = profile.value.copyWith(screenTime: screenTime);
    _validateForm();
  }

  void selectDateOfBirth(DateTime date) {
   
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    profile.value = profile.value.copyWith(dob: formattedDate);
    _validateForm();
  }

  bool get canAddMoreProfiles => userProfiles.length < 5;

  void navigateToProfileSetup() {
    AppRouter.toProfileSetup();
  }

  Future<void> selectProfile(UserProfile selectedProfile) async {
    Get.snackbar(
      'Profile Selected',
      'Switched to ${selectedProfile.name} profile',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    String userString = jsonEncode(selectedProfile);

    await _storageHelper.storeItem(key: "current_profile", value: userString);

    Get.to(() => BottomNav(), arguments: [{'profile': selectedProfile}]);    // Get.toNamed('/home', arguments: {'profile_id': selectedProfile.id});
  }

  Future<void> refreshProfiles() async {
    _initializeHttpClient();
    await Future.delayed(Duration(milliseconds: 100));
    await fetchUserProfiles();
  }

  Future<void> _saveToStorage() async {
    final profileData = {
      'type': profile.value.profileType,
      'name': profile.value.name,
      'email': userEmail,
      'dateOfBirth': profile.value.dob,
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


  Future<void> loadAuthTokenAndFetchProfiles() async {
    await _loadAuthToken();

    _initializeHttpClient();
    await Future.delayed(Duration(milliseconds: 100));
    await fetchUserProfiles();
  }
}
