import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/view/subscription/model/subscription.dart';
import 'package:godly_seed_app/view/subscription/screen/subscription_screen.dart';
import 'package:godly_seed_app/view/movie/screens/play_movie.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/network/api_client.dart';
import 'package:godly_seed_app/constants/endpoints.dart';

class SubscriptionController extends GetxController {
  final selectedPlan = 0.obs;
  final RxBool isSubmitting = false.obs;

  final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      duration: '12 MONTHS',
      price: 'N 900.00',
      monthlyPrice: '/month',
      totalPrice: 'N 11,800.00',
      isBestOffer: true,
    ),
    SubscriptionPlan(
      duration: '6 MONTHS',
      price: 'N 1,500.00',
      monthlyPrice: '/month',
      totalPrice: 'N 9,000.00',
    ),
    SubscriptionPlan(
      duration: '1 MONTH',
      price: 'N 1,900.00',
      monthlyPrice: '/month',
      totalPrice: 'N 1,900.00',
    ),
  ];

  final List<Feature> features = [
    Feature(
      icon: Icons.movie,
      title: 'Unlimited Movie Access',
      description: 'Unlock all Christian movies.',
    ),
    Feature(
      icon: Icons.download,
      title: 'Watch Offline Anytime',
      description: 'Download and enjoy your favorite movie anytime.',
    ),
    Feature(
      icon: Icons.block,
      title: 'Ad-free Viewing',
      description: 'Watch without interruptions and distractions.',
    ),
  ];

  void selectPlan(int index) {
    selectedPlan.value = index;
  }

  void subscribe() {
     
    Get.snackbar(
      'Success',
      'Subscription activated successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    final args = Get.arguments as Map<dynamic, dynamic>?;
    final String movieTitle = args != null && args['movieTitle'] != null ? args['movieTitle'].toString() : 'Movie';
    final String videoUrl = args != null && args['videoUrl'] != null ? args['videoUrl'].toString() : '';

    if (videoUrl.isNotEmpty) {
      Get.off(() => VideoPlayerScreen(movieTitle: movieTitle, videoUrl: videoUrl), arguments: args);
    } else {
      Get.back();
    }
  }

  Future<void> _recordFreeWatchProgress() async {
    try {
      isSubmitting.value = true;
      final storage = LocalStorageHelper();
      final user = await storage.getUser();
      final profile = await storage.getProfile();
      final args = Get.arguments as Map<dynamic, dynamic>?;

      final String movieId = args != null && args['movieId'] != null ? args['movieId'].toString() : '';

      if (user?.uniqueId == null || profile?.id == null || movieId.isEmpty) {
        Get.snackbar('Error', 'Missing required data for free watch', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final api = ApiClient(appbaseurl: Endpoints.baseUrl);

      final now = DateTime.now();
      final body = {
        "user_id": (user!.email != null && user.email!.isNotEmpty) ? user.email! : (user.uniqueId ?? ''),
        "profile_id": profile!.id!,
        "movie_id": movieId,
        "current_watch_time": "0",
        "watch_duration": "0",
        "watched_at": now.toIso8601String().replaceFirst('T', ' ').split('.').first,
      };

      final response = await api.postRequest(url: Endpoints.freeWatch, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.body.isEmpty) {
            // consider success when empty body
            return;
          }
          final decoded = json.decode(response.body);
          final int? code = decoded is Map<String, dynamic>
              ? (decoded['response_code'] ?? decoded['status_code']) as int?
              : null;
          final String? message = decoded is Map<String, dynamic>
              ? (decoded['response_message'] ?? decoded['message']) as String?
              : null;
          if (code != null && code >= 200 && code < 300) {
            if (message != null && message.isNotEmpty) {
              Get.snackbar('Success', message, backgroundColor: Colors.green, colorText: Colors.white);
            }
          } else if (message != null && message.isNotEmpty) {
            Get.snackbar('Notice', message, backgroundColor: Colors.orange, colorText: Colors.white);
          }
        } catch (_) {
          // swallow JSON issues; treat as success already
        }
      } else {
        Get.snackbar('Warning', 'Unable to record free watch', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }

  void continueWithAds() async {
     
    final args = Get.arguments as Map<dynamic, dynamic>?;
    final String movieTitle = args != null && args['movieTitle'] != null ? args['movieTitle'].toString() : 'Movie';
    final String videoUrl = args != null && args['videoUrl'] != null ? args['videoUrl'].toString() : '';

    await _recordFreeWatchProgress();

    if (videoUrl.isNotEmpty) {
      Get.off(() => VideoPlayerScreen(movieTitle: movieTitle, videoUrl: videoUrl), arguments: args);
    } else {
      Get.back();
    }
  }

  void upgradeNow() {

    Get.to(() => PremiumSubscriptionView());
  }

  void continueWatching() {
    Get.back();
  }
}