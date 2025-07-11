import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:godly_seed_app/view/login/models/login_response.dart';

import '../../utils/helpers.dart';
import '../../view/profile_setup/model/profile_response.dart';

class LocalStorageHelper {
  final storage = const FlutterSecureStorage();
    static const String _userKey = 'user';
  static const String _accessTokenKey = 'token';

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
  Future<UserProfile?> getProfile() async {
    try {
      var userString = await storage.read(key: "current_profile");
      UserProfile? newThing = UserProfile.fromJson(jsonDecode(userString!.trim()));

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
      return await storage.read(key: _accessTokenKey);
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
  Future<void> clearAll() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      logItem(e);
    }
  }

  static Future<void> clearTokens() async {}

}
