import 'dart:convert';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userKey = 'user';
  static const String _accessTokenKey = 'access_token';
  static const String _isRememberMeKey = 'isRememberMe';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userProfileKey = 'user_profile';
  static const String _profileModelKey = 'profile_model';


  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  static Future<void> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);
    } catch (e) {
      print('Error saving access token: $e');
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  static Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

 
  static Future<void> saveRememberMe(bool isRememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isRememberMeKey, isRememberMe);
    } catch (e) {
      print('Error saving remember me: $e');
    }
  }

  static Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isRememberMeKey) ?? false;
    } catch (e) {
      print('Error getting remember me: $e');
      return false;
    }
  }


  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
    } catch (e) {
      print('Error saving login status: $e');
    }
  }

  static Future<bool> getLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error getting login status: $e');
      return false;
    }
  }

  static Future<void> saveUserProfile(Map<String, dynamic> userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userProfileKey, jsonEncode(userProfile));
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString(_userProfileKey);
      
      if (profileData != null) {
        return jsonDecode(profileData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  static Future<void> saveProfileModel(Map<String, dynamic> profileModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileModelKey, jsonEncode(profileModel));
    } catch (e) {
      print('Error saving profile model: $e');
    }
  }

  static Future<Map<String, dynamic>?> getProfileModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelData = prefs.getString(_profileModelKey);
      
      if (modelData != null) {
        return jsonDecode(modelData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting profile model: $e');
    }
    return null;
  }

  // Clear methods
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_userKey),
        prefs.remove(_accessTokenKey),
        prefs.remove(_isRememberMeKey),
        prefs.remove(_isLoggedInKey),
      ]);
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  static Future<void> saveProfiles(profiles) async {}
}