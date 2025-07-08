import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/view/login/models/login_response.dart';
import 'package:godly_seed_app/view/profile_setup/controller/profile_controller.dart';
import 'package:godly_seed_app/view/profile_setup/model/profile_model.dart';

class ProfileSelectionScreen extends GetView<ProfileController> {
  const ProfileSelectionScreen({super.key});

  Widget _buildExistingProfile(Profiles profile) {
    return GestureDetector(
      onTap: () => controller.selectProfile(profile),
      child: Container(
        width: 120,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: profile.ageGroup?.toLowerCase() == 'adult'
                    ? Colors.blue[100] 
                    : Colors.pink[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Icon(
                profile.ageGroup?.toLowerCase() == 'adult'
                    ? Icons.person 
                    : Icons.child_care,
                size: 40,
                color: profile.ageGroup?.toLowerCase() == 'adult'
                    ? Colors.blue[600] 
                    : Colors.pink[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.name.isNotEmpty ? profile.name : 'No Name',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
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
        width: 120,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
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
                size: 40,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Profile',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              controller.canAddMoreProfiles 
                  ? '${5 - controller.userProfiles.length} left'
                  : 'Limit reached',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileGrid() {
    return Obx(() {
      // if (controller.isLoading.value) {
      //   return const Center(
      //     child: CircularProgressIndicator(),
      //   );
      // }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refreshProfiles(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

     
      List<Widget> profileWidgets = [];
      
  
      for (var profile in controller.userProfiles) {
        profileWidgets.add(_buildExistingProfile(profile));
      }
      
     
      if (controller.canAddMoreProfiles) {
        profileWidgets.add(_buildAddProfileCard());
      }

      if (profileWidgets.isEmpty) {
      
        profileWidgets.add(_buildAddProfileCard());
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: profileWidgets,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Who\'s watching?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a profile to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
         
            Expanded(
              child: Center(
                child: _buildProfileGrid(),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                
                  Obx(() => Text(
                    '${controller.userProfiles.length} of 5 profiles created',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )),
                  const SizedBox(height: 16),
                  
                
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                       
                        AppRouter.toProfileSetup();
                        
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Manage Profiles',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();
        
        return FloatingActionButton(
          onPressed: () => controller.refreshProfiles(),
          backgroundColor: Colors.brown[400],
          child: const Icon(Icons.refresh, color: Colors.white),
        );
      }),
    );
  }
}