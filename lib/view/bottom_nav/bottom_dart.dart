import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:movie_app/view/downloads_screen/screen/downloads_screen.dart';
import 'package:movie_app/view/settings/screen/settings_screen.dart';

import '../../constants/color_palette.dart';
import '../favourites/screen/favourites_screen.dart';
import '../home/screens/home_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int visit = 0;
  double height = 30;
  List<TabItem> items = [
    const TabItem(
      icon: Icons.home,
      title: 'Home',
    ),
    const TabItem(
      icon: Icons.download,
      title: 'Downloads',
    ),
    const TabItem(
      icon: Icons.list,
      title: 'My List',
    ),
    const TabItem(
      icon: Icons.settings,
      title: 'Settings',
    ),
  ];

  var argumentData = Get.arguments;

  var profile;

  @override
  void initState() {
    // profile = argumentData[0]['profile'];

    super.initState();
  }

  List<Widget> pages = [
    HomeScreen(),
    DownloadsScreen(),
    FavouritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[visit],
      bottomNavigationBar: BottomBarDefault(
        items: items,
        backgroundColor: Colors.white,
        color: Colors.grey,
        indexSelected: visit,
        colorSelected: primaryColor,
        onTap: (int index) {
          setState(() {
            visit = index;
          });

        },
      ),
    );
  }
}
