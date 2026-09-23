import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:movie_app/constants/color_palette.dart';
import 'package:movie_app/utils/helpers.dart';
import 'package:movie_app/view/profile_setup/screens/profile_setup_screen.dart';
import 'package:movie_app/view/profile_setup/controller/profile_controller.dart';

import '../../widgets/curved_top.dart';
import '../model/profile_response.dart';

class ProfileSetupIntroScreen extends StatefulWidget {
  const ProfileSetupIntroScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupIntroScreen> createState() => _ProfileSetupIntroScreenState();
}

class _ProfileSetupIntroScreenState extends State<ProfileSetupIntroScreen> {
  final List<String> _backgrounds = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
  ];
  int _currentBg = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentBg = (_currentBg + 1) % _backgrounds.length;
      });
    });
    final controller = Get.find<ProfileController>();
    controller.userProfiles.clear(); // Ensure fresh fetch
    controller.loadAuthTokenAndFetchProfiles();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildExistingProfile(UserProfile profile) {
    return GestureDetector(
       onTap: () => Get.find<ProfileController>().selectProfile(profile),
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: profile.ageGroup!.toLowerCase() == 'adult'
                    ? Colors.blue[100]
                    : Colors.pink[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Icon(
                profile.ageGroup!.toLowerCase() == 'adult'
                    ? Icons.person
                    : Icons.child_care,
                size: 32,
                color: profile.ageGroup!.toLowerCase() == 'adult'
                    ? Colors.blue[600]
                    : Colors.pink[600],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.name!.isNotEmpty ? profile.name! : 'No Name',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileCard() {
    return GestureDetector(
     onTap: () => Get.find<ProfileController>().navigateToProfileSetup(),
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 32,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileList() {
    return Obx(() {
      final controller = Get.find<ProfileController>();
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final profiles = controller.userProfiles;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      // Always show Add card if no profiles, even if error
      if (profiles.isEmpty) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAddProfileCard(),
          ],
        );
      }

      List<Widget> widgets = profiles
          .map((profile) => _buildExistingProfile(profile))
          .toList();
      if (controller.canAddMoreProfiles) {
        widgets.add(_buildAddProfileCard());
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: widgets),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 80),
              child: Image.network(
                _backgrounds[_currentBg],
                key: ValueKey(_backgrounds[_currentBg]),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.expand(),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 50),

                const Spacer(),
                CurvedTopContainer(
                  height: 400,
                  color: kWhiteColor,
                  child:                 Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Set up your profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildProfileList(),
                          const SizedBox(height: 60),
                          InkWell(
                            onTap: () {
                              logout();
                            },
                            child:  const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}