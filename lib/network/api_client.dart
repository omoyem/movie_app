import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../data/local/secure_storage_helper.dart';
import '../constants/endpoints.dart';
import '../utils/helpers.dart';
import '../utils/httpClient_helper.dart';

class ApiClient extends GetConnect implements GetxService {
  late String token = Endpoints.baseUrl;
  late String appbaseurl;
  late Map<String, String> _mainHeader;
  LocalStorageHelper localStorageHelper = LocalStorageHelper();

  ApiClient({required String appbaseurl}) {
    baseUrl = appbaseurl;

    timeout = const Duration(seconds: 30);
    maxAuthRetries = 1;
    _mainHeader = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

// POST METHOD
  Future<http.Response> getRequest({
    required String url,
  }) async {
    try {
      http.Response response;
      // The below request is the same as above.
      var token = await localStorageHelper.retrieveItem(key: "token");

      logItem(url);

      _mainHeader = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token",
        "Membership-code": "0000514121"
      };

      final uri = Uri.parse(Endpoints.baseUrl + url);

      final client =
      IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
        response = await client.get(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
        );


      if (response.statusCode == 401) {
        logout();
      }

      logItem("667777777===========================");

      logItem(response.body.toString());
      return response;
    } catch (e) {
      logItem(
          ".................................................................");
      logItem(e.toString());
      throw Exception(e);
    }
  }

// POST METHOD
  Future<Response?> deleteRequest({
    required String url,
  }) async {
    try {
      Response response;
      // The below request is the same as above.
      var token = await localStorageHelper.retrieveItem(key: "token");

      logItem(url);

      logItem(url);

      _mainHeader = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token",
        "Membership-code": "0000514121"
      };
      response = await delete(url, headers: _mainHeader);

      if (response.statusCode == 401) {
        logout();
      }

      logItem("667777777===========================");

      logItem(response.body.toString());
      return response;
    } catch (e) {
      logItem(e.toString());
      throw Exception(e);
    }
  }

// POST METHOD
  Future<http.Response> postRequest(
      {required String url, required Map<dynamic, dynamic> data}) async {
    try {
      http.Response response;
      // The below request is the same as above.
      logItem("--------------------------------------");
      var token = await localStorageHelper.retrieveItem(key: "token");

      _mainHeader = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      logItem(data);
      logItem(url);
      final uri = Uri.parse(Endpoints.baseUrl + url);

      final client =
          IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
      try {
        final response = await client.post(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: jsonEncode(data),
        );

        // response = await post(url, data, headers: _mainHeader);

        if (response.statusCode == 401) {
          logout();
        }

        logItem("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
        logItem(response.statusCode, title: "Response thingssy");
        logItem(response.body.toString());
        return response;
      } catch (e) {
        logItem(e.toString());
        throw Exception(e);
      }
    } catch (e) {
      logItem(e.toString());
      throw Exception(e);
    }
  }

// POST METHOD
  Future<Response?> postUploadRequest(
      {required String url, required List<int> image}) async {
    try {
      final form = FormData({
        'file': MultipartFile(image, filename: 'avatar.png'),
      });

      Response response;
      // The below request is the same as above.
      response = await post(url, form);

      if (response.statusCode == 401) {
        logout();
      }

      logItem("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
      logItem(response.body.toString());
      return response;
    } catch (e) {
      logItem(e.toString());
      throw Exception(e);
    }
  }

  // PUT METHOD
  Future<Response?> putUploadRequest(
      {required String url, required dynamic image}) async {
    try {
      final form = FormData({
        'attachment': MultipartFile(image,
            filename: 'avatar.png', contentType: 'image/jpeg'),
      });
      token = (await localStorageHelper.retrieveItem(key: "token"))!;

      logItem(url, title: "5555555555 the URL 5555555555555");

      _mainHeader = {
        "Authorization": "Bearer $token",
      };

      Response response;
      // The below request is the same as above.
      response = await put(url, form, headers: _mainHeader);

      if (response.statusCode == 401) {
        logout();
      }

      logItem("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
      logItem(response.body.toString());
      return response;
    } catch (e) {
      logItem(e.toString());
      throw Exception(e);
    }
  }

// POST METHOD
  Future<Response> putRequest(
      {required String url, required Map<dynamic, dynamic> data}) async {
    try {
      Response response;

      var token = await localStorageHelper.retrieveItem(key: "token");

      _mainHeader = {
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $token",
        "Membership-code": "0000514121"
      };

      logItem(baseUrl);
      logItem(url);
      logItem(_mainHeader);
      logItem(data);

      response = await put(url, data, headers: _mainHeader);

      if (response.statusCode == 401) {
        logout();
      }

      logItem("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
      logItem(response.body.toString());
      return response;
    } catch (e) {
      logItem(e.toString());
      throw Exception(e);
    }
  }
}
