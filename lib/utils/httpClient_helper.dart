import 'dart:io';
import 'package:flutter/foundation.dart';

class InsecureHttpClientHelper {
  static HttpClient createInsecureHttpClient() {
    return HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          print('🔐 Certificate Details:');
          print('   Subject: ${cert.subject}');
          print('   Issuer: ${cert.issuer}');
          print('   Host: $host');
          print('   Port: $port');
          print('   Allowing insecure connection...');
        }
        
        return true;
      }
      ..connectionTimeout = Duration(seconds: 30)
      ..idleTimeout = Duration(seconds: 30);
  }
  
 
  static HttpClient createSelectiveInsecureHttpClient({List<String>? allowedHosts}) {
    return HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (kDebugMode) {
          print('🔐 Certificate validation for: $host');
          print('   Subject: ${cert.subject}');
          print('   Issuer: ${cert.issuer}');
        }
        
        // In debug mode, allow all
        if (kDebugMode) {
          return true;
        }
 
        if (allowedHosts != null && allowedHosts.isNotEmpty) {
          bool isAllowed = allowedHosts.any((allowedHost) => 
            host.toLowerCase().contains(allowedHost.toLowerCase()));
          
          if (kDebugMode) {
            print('   Host $host ${isAllowed ? "allowed" : "blocked"}');
          }
          
          return isAllowed;
        }
        
    
        return false;
      }
      ..connectionTimeout = Duration(seconds: 30)
      ..idleTimeout = Duration(seconds: 30);
  }
}