import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:movie_app/constants/app_router.dart';

import 'package:http/http.dart' as http;
import 'package:movie_app/constants/endpoints.dart';

import 'network/http_fix.dart';
import 'network/mock_backend.dart';


void main() {
  HttpOverrides.global = MyHttpOverrides(); // ⛔️ Do not use in production

  if (Endpoints.useMockData) {
    // No real backend yet: answer every request with dummy data.
    http.runWithClient(() => runApp(MyApp()), MockBackend.client);
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Movie App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Lexend',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.splash,
      getPages: AppRouter.routes,
    );
  }
}

