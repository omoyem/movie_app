import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';
import 'package:godly_seed_app/view/widgets/background_widget.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final LocalStorageHelper _storageHelper = LocalStorageHelper();
  
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAuthenticationCheck();
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

  void _startAuthenticationCheck() {
    Future.delayed(Duration(seconds: 3), () async {
      await _checkUserAuthentication();
    });
  }

  Future<void> _checkUserAuthentication() async {
    try {
  
      bool isLoggedIn = await _storageHelper.hasItem(key: _isLoggedInKey);
      bool hasAuthToken = await _storageHelper.hasItem(key: _authTokenKey);
      bool hasUserId = await _storageHelper.hasItem(key: _userIdKey);
      
    
      String? loginStatus = await _storageHelper.retrieveItem(key: _isLoggedInKey);
      bool isLoginStatusValid = loginStatus == 'true';
      
      bool userIsAuthenticated = hasAuthToken && hasUserId && isLoginStatusValid;
      
      if (userIsAuthenticated) {
     
        await _validateTokenWithServer();
      } else {
        _navigateToOnboarding();
      }
      
    } catch (e) {
      print("Error checking authentication: $e");
    
      _navigateToOnboarding();
    }
  }

  Future<void> _validateTokenWithServer() async {
    try {
      String? authToken = await _storageHelper.retrieveItem(key: _authTokenKey);
      
      if (authToken != null) {
  
        bool isTokenValid = await _performTokenValidation(authToken);
        
        if (isTokenValid) {
          _navigateToHome();
        } else {
      
          await _clearAuthenticationData();
          _navigateToOnboarding();
        }
      } else {
        _navigateToOnboarding();
      }
    } catch (e) {
      print("Token validation error: $e");
      _navigateToOnboarding();
    }
  }

  Future<bool> _performTokenValidation(String token) async {
    try {
      
      return token.isNotEmpty;
    } catch (e) {
      print("Token validation failed: $e");
      return false;
    }
  }

  Future<void> _clearAuthenticationData() async {
    await _storageHelper.deleteItem(key: _authTokenKey);
    await _storageHelper.deleteItem(key: _userIdKey);
    await _storageHelper.deleteItem(key: _isLoggedInKey);
  }

  void _navigateToHome() {
    
    AppRouter.toHome(); 
  }

  void _navigateToOnboarding() {
    AppRouter.toOnboarding();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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