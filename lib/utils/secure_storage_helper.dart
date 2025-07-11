import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'helpers.dart';

class LocalStorageHelper {
  final storage = const FlutterSecureStorage();

  storeItem({required String key, required String value}) async {
    try {
      await storage
          .write(key: key, value: value)
          .then((value) => print("Values saved successfully"));
    } catch (e) {
      logItem(e);
    }
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  Future<String?> retrieveItem({required String key}) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      logItem(e);
    }
    return null;
  }

  Future<void> deleteItem({required String key}) async {
    try {
      await storage.delete(key: key).then(
            (value) => print("Item with key '$key' deleted successfully"),
          );
    } catch (e) {
      logItem(e);
    }
  }

  Future<void> clearAll() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      logItem(e);
    }
  }
}
