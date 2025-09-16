import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'dart:convert';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/network/api_client.dart';
import 'package:godly_seed_app/view/movie/bindings/movie_binding.dart';
import 'package:godly_seed_app/view/movie/screens/play_movie.dart';
import 'package:http/http.dart' as http;
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';

import '../../../data/models/movie.dart';

class MovieController extends GetxController {
  final Rx<Movies?> currentMovie = Rx<Movies?>(null);
  final RxList<MovieModel> similarMovies = <MovieModel>[].obs;
  final RxString similarMoviesMessage = ''.obs;
  final RxBool isInMyList = false.obs;

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);

  @override
  void onInit() {
    super.onInit();
    currentMovie.value = Get.arguments as Movies?;
    loadSimilarMovies();
  }

  Future<void> loadSimilarMovies() async {
    if (currentMovie.value == null) return;
    try {
      final requestBody = {"movie_id": currentMovie.value!.id};
      http.Response response = await apiClient.postRequest(
        url: Endpoints.getSimilarMovies,
        data: requestBody,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] == 200 && data['data'] != null) {
          final List<MovieModel> fetched = (data['data'] as List)
              .map((json) {
                final movie = Movies.fromJson(json);
               
                List<String> categories = [];
                try {
                  if (movie.tags != null && movie.tags!.isNotEmpty) {
                    final tagsList = jsonDecode(movie.tags!) as List;
                    categories = tagsList.map((tag) => tag['value'].toString()).toList();
                  }
                } catch (e) {
                  categories = ['General'];
                }
             
                String imageUrl = movie.coverPhotoPath != null && movie.coverPhotoPath!.startsWith('http')
                  ? movie.coverPhotoPath!
                  : Endpoints.imageBaseUrl + (movie.coverPhotoPath ?? '');
                return MovieModel(
                  id: int.tryParse(movie.id ?? '0') ?? 0,
                  title: movie.title ?? '',
                  year: (movie.releaseDate ?? '').split('-').first,
                  seasons: '1 season',
                  imageUrl: imageUrl,
                  fileUrl: movie.filePath ?? '',
                  description: movie.description ?? '',
                  categories: categories,
                  episodes: [],
                );
              })
              .toList();
          similarMovies.value = fetched;
          similarMoviesMessage.value = '';
        } else {
          similarMovies.clear();
          similarMoviesMessage.value = data['response_message'] ?? 'No similar movies found.';
        }
      } else {
        similarMovies.clear();
        similarMoviesMessage.value = 'No similar movies found.';
      }
    } catch (e) {
      similarMovies.clear();
      similarMoviesMessage.value = 'No similar movies found.';
      print('Error loading similar movies: ' + e.toString());
    }
  }

  void toggleMyList() {
    isInMyList.value = !isInMyList.value;
  }

  void playMovie() {
    if (currentMovie.value == null) return;
    final movie = currentMovie.value!;
    final String movieId = movie.id ?? '';
    final String movieTitle = movie.title ?? 'Movie';
    final String videoUrl = movie.filePath ?? '';

    recordFreeWatchProgress();

    if (videoUrl.isNotEmpty) {
      Get.to(
        () => VideoPlayerScreen(movieTitle: movieTitle, videoUrl: videoUrl),
        binding: MovieBinding(),
        arguments: {
          'movieId': movieId,
          'movieTitle': movieTitle,
          'videoUrl': videoUrl,
        },
      );
    }
  }


  Future<void> recordFreeWatchProgress() async {
    try {
      final storage = LocalStorageHelper();
      final user = await storage.getUser();
      final profile = await storage.getProfile();
      final args = Get.arguments as Map<dynamic, dynamic>?;

      final String movieId = args != null && args['movieId'] != null ? args['movieId'].toString() : (currentMovie.value?.id ?? '');

      if (user?.uniqueId == null || profile?.id == null || movieId.isEmpty) {
        Get.snackbar('Error', 'Missing required data for free watch', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final now = DateTime.now();
      final body = {
        "user_id": (user!.email != null && user.email!.isNotEmpty) ? user.email! : (user.uniqueId ?? ''),
        "profile_id": profile!.id!,
        "movie_id": movieId,
        "current_watch_time": "0",
        "watch_duration": "0",
        "watched_at": now.toIso8601String().replaceFirst('T', ' ').split('.').first,
      };

      final response = await apiClient.postRequest(url: Endpoints.freeWatch, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.body.isEmpty) {
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
          // ignore JSON parse errors and treat as success
        }
      } else {
        Get.snackbar('Warning', 'Unable to record free watch', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<String?> saveWatchProgress({
    required String userId,
    required String profileId,
    required String movieId,
    required String currentWatchTime,
    required String watchDuration,
    required String watchedAt,
  }) async {
    try {
      
      final requestBody = {
        "user_id": userId,
        "profile_id": profileId,
        "movie_id": movieId,
        "current_watch_time": currentWatchTime,
        "watch_duration": watchDuration,
        "watched_at": watchedAt,
      };
      
      print('Saving watch progress request: $requestBody');
      
      final response = await apiClient.postRequest(
        url: Endpoints.saveWatchProgess,
        data: requestBody,
      );
      
      print('Watch progress response status: ${response.statusCode}');
      print('Watch progress response body: "${response.body}"');
      print('Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
      
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('Empty response body received - assuming success');
          return null;
        }
        
        try {
          final decodedResponse = json.decode(response.body);
          print('Decoded response: $decodedResponse');
          
        
          if (decodedResponse is Map<String, dynamic>) {
            final message = decodedResponse['response_message'];
            return message;
          }
          return null;
        } catch (jsonError) {
          print('JSON decode error: $jsonError');
          print('Raw response: "${response.body}"');
        
          return null;
        }
      } else if (response.statusCode == 201) {
        
        print('Watch progress saved successfully (201)');
        return null;
      } else {
        print('API returned status: ${response.statusCode}');
        print('Error response body: "${response.body}"');
        return null;
      }
    } catch (e) {
      print('Error saving watch progress: ${e.toString()}');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  Future<bool> saveWatchProgressDirect({
    required String userId,
    required String profileId,
    required String movieId,
    required String currentWatchTime,
    required String watchDuration,
    required String watchedAt,
  }) async {
    try {
      final requestBody = {
        "user_id": userId,
        "profile_id": profileId,
        "movie_id": movieId,
        "current_watch_time": currentWatchTime,
        "watch_duration": watchDuration,
        "watched_at": watchedAt,
      };
      
      print('Direct API call - Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(Endpoints.baseUrl + Endpoints.saveWatchProgess),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      print('Direct API - Response status: ${response.statusCode}');
      print('Direct API - Response body: "${response.body}"');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Direct API error: ${e.toString()}');
      return false;
    }
  }
}