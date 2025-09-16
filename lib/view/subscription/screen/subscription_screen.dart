
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/view/subscription/controller/subscription_controller.dart';
import 'package:godly_seed_app/view/subscription/screen/free_trial_screen.dart';
import 'package:godly_seed_app/view/widgets/feature_item.dart';
import 'package:godly_seed_app/view/widgets/subscription_card.dart';

class PremiumSubscriptionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B4513),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Crown Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Title
                    const Text(
                      'Enjoy maximum content with Premium',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    const Text(
                      'Maximum free movies exceeded. Upgrade now to premium to enjoy unlimited access to Christian movies on our GODLY SEED platform.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Features
                    ...controller.features.map((feature) => 
                      FeatureItem(feature: feature)
                    ).toList(),
                    
                    const SizedBox(height: 40),
                    
                    // Subscription Plans
                    Obx(() => Column(
                      children: controller.plans.asMap().entries.map((entry) {
                        final index = entry.key;
                        final plan = entry.value;
                        return SubscriptionPlanCard(
                          plan: plan,
                          isSelected: controller.selectedPlan.value == index,
                          onTap: () => controller.selectPlan(index),
                        );
                      }).toList(),
                    )),
                    
                    const SizedBox(height: 30),
                    
                    // Subscribe Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.subscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Subscribe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Continue with ads
                    TextButton(
                      onPressed: controller.continueWithAds,
                      child: const Text(
                        'Continue watching with ads',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B4513),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Demo Free Trial Button
                    TextButton(
                      onPressed: () => Get.to(() => FreeTrialScreen(), arguments: Get.arguments),
                      child: const Text(
                        'View Free Trial Screen',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

