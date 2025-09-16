import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/utils/helpers.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';
import 'package:godly_seed_app/view/widgets/background_widget.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final LocalStorageHelper _storageHelper = LocalStorageHelper();

  static const String _authTokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
  
    _delayedTokenValidation();
  }

  void _delayedTokenValidation() {
    Future.delayed(Duration(milliseconds: 1500), () {
      _validateTokenWithServer();
    });
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  Future<void> _validateTokenWithServer() async {
    try {
      print('🔍 Starting token validation...');
    
      String? authToken = await _getAuthToken();
      String? userEmail = await _getUserEmail();

      print('🔐 Auth token found: ${authToken != null && authToken.isNotEmpty}');
      print('👤 User email found: ${userEmail != null && userEmail.isNotEmpty}');

      if (authToken != null && authToken.isNotEmpty) {
        bool isTokenValid = await _performTokenValidation(authToken);
        
        print('✅ Token validation result: $isTokenValid');

        if (isTokenValid) {
        
          _navigateToSelectProfile(authToken, userEmail);
        } else {
          print('❌ Token invalid, clearing auth data');
          await _clearAuthenticationData();
          _navigateToOnboarding();
        }
      } else {
        print('⚠️ No auth token found, going to onboarding');
        _navigateToOnboarding();
      }
    } catch (e) {
      print("❌ Token validation error: $e");
      await _clearAuthenticationData();
      _navigateToOnboarding();
    }
  }

  Future<String?> _getAuthToken() async {
    try {
    
      String? token = await _storageHelper.retrieveItem(key: _authTokenKey);
      if (token != null && token.isNotEmpty) {
        print('🔐 Token found in secure storage');
        return token;
      }

      token = await _storageHelper.retrieveItem(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        print('🔐 Token found in auth_token key');
        return token;
      }
      token = await _storageHelper.retrieveItem(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        print('🔐 Token found in access_token key');
        return token;
      }

    
      token = await LocalStorageHelper.getAccessTokenMain();
      if (token != null && token.isNotEmpty) {
        print('🔐 Token found via getAccessTokenMain');
        return token;
      }

      print('⚠️ No token found in any storage');
      return null;
    } catch (e) {
      print('❌ Error retrieving auth token: $e');
      return null;
    }
  }

  Future<String?> _getUserEmail() async {
    try {
   
      String? email = await _storageHelper.retrieveItem(key: 'user_email');
      if (email != null && email.isNotEmpty) {
        return email;
      }

      email = await _storageHelper.retrieveItem(key: _userIdKey);
      if (email != null && email.isNotEmpty) {
        return email;
      }

      return null;
    } catch (e) {
      print('❌ Error retrieving user email: $e');
      return null;
    }
  }

  Future<bool> _performTokenValidation(String token) async {
    try {
      print('🔍 Validating token: ${token.substring(0, 10)}...');
      
      
      await _storageHelper.storeItem(key: _authTokenKey, value: token);
      await _storageHelper.storeItem(key: 'auth_token', value: token);
      await _storageHelper.storeItem(key: 'access_token', value: token);
      
    
      bool isValid = token.isNotEmpty && token.length > 10;
      
      if (isValid) {
        print('✅ Token appears valid');
      
        await _storageHelper.storeItem(key: _isLoggedInKey, value: 'true');
      }
      
      return isValid;
    } catch (e) {
      print("❌ Token validation failed: $e");
      return false;
    }
  }

  Future<void> _clearAuthenticationData() async {
    try {
      await _storageHelper.deleteItem(key: _authTokenKey);
      await _storageHelper.deleteItem(key: 'auth_token');
      await _storageHelper.deleteItem(key: 'access_token');
      await _storageHelper.deleteItem(key: _userIdKey);
      await _storageHelper.deleteItem(key: 'user_email');
      await _storageHelper.deleteItem(key: _isLoggedInKey);
      await _storageHelper.deleteItem(key: 'current_profile');
      print('🗑️ Authentication data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }

  void _navigateToHome() {
    AppRouter.toHome();
  }

  void _navigateToSelectProfile(String? token, String? email) {
    print('🚀 Navigating to profile selection with token and email');
    
    // Use Get.offAllNamed to clear the navigation stack
    // and pass the token and email as arguments
    Get.offAllNamed('/profileSelection', arguments: {
      'token': token,
      'email': email,
      'from_splash': true,
    });
  }

  void _navigateToOnboarding() {
    print('🚀 Navigating to onboarding');
    AppRouter.toOnboarding();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Add small delay before revalidating to avoid conflicts
      Future.delayed(Duration(milliseconds: 500), () {
        _validateTokenWithServer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageWidget.asset(
        assetPath: appBackground,
        fit: BoxFit.cover,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLogoWidget(size: 200),
                      SizedBox(height: 24),
                      // Add loading indicator
                      Container(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}