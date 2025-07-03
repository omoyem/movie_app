// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


class InsecureHttpClientHelper {
  static HttpClient createInsecureHttpClient() {
    return HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          print('🔐 Certificate Details:');
          print('   Subject: \\${cert.subject}');
          print('   Issuer: \\${cert.issuer}');
          print('   Host: \\${host}');
          print('   Port: \\${port}');
        }
        return kDebugMode;
      };
  }
}
