import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageHelper {
  final storage = const FlutterSecureStorage();
    static const String _userKey = 'user';
  static const String _accessTokenKey = 'access_token';
  static const String _isRememberMeKey = 'isRememberMe';
  static const String _isLoggedInKey = 'isLoggedIn';

  
  storeItem({required String key, required String value}) async {
    try {
      await storage
          .write(key: key, value: value)
          .then((value) => print("Values saved successfully"));
    } catch (e) {
      print("Error storing item: $e");
    }
  }
  
  Future<String?> retrieveItem({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      print("Error retrieving item: $e");
    }
    return null;
  }
  
  Future<void> deleteItem({required String key}) async {
    try {
      await storage.delete(key: key);
    } catch (e) {
      print("Error deleting item: $e");
    }
  }
  
  Future<bool> hasItem({required String key}) async {
    try {
      String? value = await storage.read(key: key);
      return value != null && value.isNotEmpty;
    } catch (e) {
      print("Error checking item: $e");
      return false;
    }
  }
  


  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }


  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      try {
        return User.fromJson(jsonDecode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }


  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> saveRememberMe(bool isRememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isRememberMeKey, isRememberMe);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isRememberMeKey) ?? false;
  }

  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }


  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_isRememberMeKey);
    await prefs.remove(_isLoggedInKey);
  }


  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> clearTokens() async {}

}
