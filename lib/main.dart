import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:godly_seed_app/constants/app_router.dart';

import 'network/http_fix.dart';


void main() {
  HttpOverrides.global = MyHttpOverrides(); // ⛔️ Do not use in production

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Godly Seed App',
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

