import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:godly_seed_app/view/profile_setup/screens/profile_setup_screen.dart';
import 'package:godly_seed_app/view/profile_setup/controller/profile_controller.dart';
import 'package:godly_seed_app/view/profile_setup/model/profile_model.dart';

class ProfileSetupIntroScreen extends StatefulWidget {
  const ProfileSetupIntroScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupIntroScreen> createState() => _ProfileSetupIntroScreenState();
}

class _ProfileSetupIntroScreenState extends State<ProfileSetupIntroScreen> {
  final List<String> _backgrounds = [
    'assets/images/movie_1.png',
    'assets/images/movie_2.png',
    'assets/images/movie_4.png',
  ];
  int _currentBg = 0;
  Timer? _timer;
  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentBg = (_currentBg + 1) % _backgrounds.length;
      });
    });
    controller.loadAuthTokenAndFetchProfiles();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildExistingProfile(UserProfile profile) {
    return GestureDetector(
      onTap: () => controller.selectProfile(profile),
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: profile.ageGroup.toLowerCase() == 'adult'
                    ? Colors.blue[100]
                    : Colors.pink[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Icon(
                profile.ageGroup.toLowerCase() == 'adult'
                    ? Icons.person
                    : Icons.child_care,
                size: 32,
                color: profile.ageGroup.toLowerCase() == 'adult'
                    ? Colors.blue[600]
                    : Colors.pink[600],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.name.isNotEmpty ? profile.name : 'No Name',
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
     onTap: () => controller.navigateToProfileSetup(),
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
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(child: Text(controller.errorMessage.value));
      }
      List<Widget> widgets = controller.userProfiles
          .map((profile) => _buildExistingProfile(profile))
          .toList();
      if (controller.canAddMoreProfiles) {
        widgets.add(_buildAddProfileCard());
      }
      if (widgets.isEmpty) {
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
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 80),
            child: Image.asset(
              _backgrounds[_currentBg],
              key: ValueKey(_backgrounds[_currentBg]),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
    
                const Spacer(),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70),
                    ),
                  ),
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
                        const SizedBox(height: 150),
                        const Text(
                          'Select to proceed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}