import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:godly_seed_app/constants/app_router.dart';


void main() {
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

