import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:godly_seed_app/view/login/models/login_response.dart';

import '../../utils/helpers.dart';

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
  




  Future<Data?> getUser() async {
    try {
      var userString = await storage.read(key: "user");
      Data? newThing = Data.fromJson(jsonDecode(userString!.trim()));

      logItem(newThing.toJson());

      // var newUser = LoginResponse.fromJson(json.decode(userString!.trim())).data?.user;
      return newThing;
    } catch (e) {
      logItem(e);
    }
    return null;
  }
  Future<Profiles?> getProfile() async {
    try {
      var userString = await storage.read(key: "current_profile");
      Profiles? newThing = Profiles.fromJson(jsonDecode(userString!.trim()));

      logItem(newThing.toJson(), title: "Profile selected");

      // var newUser = LoginResponse.fromJson(json.decode(userString!.trim())).data?.user;
      return newThing;
    } catch (e) {
      logItem(e);
    }
    return null;
  }


  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: "token");
    } catch (e) {
      print("Error retrieving item: $e");
    }
    return null;
  }

  static Future<String?> getAccessTokenMain() async {
    try {
      const storage = FlutterSecureStorage();
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      print("Error retrieving item: $e");
    }
    return null;
  }


  static Future<void> clearTokens() async {}

}
