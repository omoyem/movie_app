import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/data/models/movie.dart';
import 'package:godly_seed_app/data/models/user.dart';
import 'package:godly_seed_app/utils/httpClient_helper.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart';
import 'package:godly_seed_app/constants/endpoints.dart';

class HomeController extends GetxController {
  final RxList<MovieModel> featuredMovies = <MovieModel>[].obs;
  final RxList<MovieModel> topMovies = <MovieModel>[].obs;
  final RxList<MovieModel> continueWatching = <MovieModel>[].obs;
  final RxString searchText = ''.obs;
  late RxString username = ''.obs;
  final RxInt currentCarouselIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString userId = ''.obs;
  final RxString profileId = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['profile_id'] != null) {
        profileId.value = args['profile_id'].toString();
        print('DEBUG: Received profile_id: ${profileId.value}');
      } else {
        print('DEBUG: No profile_id in arguments');
      }
      if (args['email'] != null) {
        userId.value = args['email'].toString();
        print('DEBUG: Received user_id (email) from arguments: ${userId.value}');
      }
    }
    loadUserName().then((_) async {
      if (userId.value.isEmpty && args != null && args is Map && args['email'] != null) {
        userId.value = args['email'].toString();
        print('DEBUG: Fallback userId from arguments: ${userId.value}');
      }
      print('DEBUG: userId: ${userId.value}, profileId: ${profileId.value}');
      loadMoviesFromApi();
    });
  }

  Future<void> loadUserName() async {
    try {
      User? user = await StorageService.getUser();
      if (user != null) {
        username.value = user.fullName.isNotEmpty ? user.fullName : user.email;
        userId.value = user.email;
        print('DEBUG: Loaded userId: ${userId.value}, username: ${username.value}');
      } else {
        print('DEBUG: No user found in storage');
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }


  Future<void> loadMoviesFromApi() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (userId.value.isEmpty || profileId.value.isEmpty) {
        throw Exception('User ID or Profile ID not available');
      }

      final response = await _getMoviesFromApi(
        userId: userId.value,
        profileId: profileId.value,
      );

      if (response.responseCode == 200) {
        final apiMovies = response.data.movies;
        final movieModels = apiMovies.map((apiMovie) => apiMovie.toMovieModel()).toList();

        if (movieModels.isNotEmpty) {
          
          featuredMovies.value = movieModels.take(5).toList();
         
          topMovies.value = movieModels.length > 5 
              ? movieModels.skip(5).toList() 
              : movieModels;
          
        
          continueWatching.value = movieModels.take(3).toList();
        }
      } else {
        throw Exception(response.responseMessage);
      }
    } catch (e) {
      print('Error loading movies from API: $e');
      errorMessage.value = 'Failed to load movies: ${e.toString()}';
      
      loadFallbackMovies();
    } finally {
      isLoading.value = false;
    }
  }

  Future<MoviesResponse> _getMoviesFromApi({
    required String userId,
    required String profileId,
    int page = 1,
    int perPage = 10,
  }) async {
    final token = await LocalStorageHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    final uri = Uri.parse(Endpoints.baseUrl + Endpoints.getMovies)
      .replace(queryParameters: {
        "user_id": userId,
        "profile_id": profileId,
        "page": page.toString(),
        "per_page": perPage.toString(),
      });

    final client = IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
    try {
      final response = await client.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MoviesResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load movies: \\${response.statusCode} - \\${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    } finally {
      client.close();
    }
  }

  void loadFallbackMovies() {
  
    featuredMovies.value = [];
    topMovies.value = [];
    continueWatching.value = [];
  }


  Future<void> refreshMovies() async {
    await loadMoviesFromApi();
  }

  void updateSearchText(String value) {
    searchText.value = value;
  
  }

  void updateCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }

  void navigateToMovieDetails(MovieModel movie) {
    Get.toNamed(AppRouter.movie, arguments: movie);
  }


  void handleApiError(String error) {
    errorMessage.value = error;
    Get.snackbar(
      'Error',
      error,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

 
  void clearError() {
    errorMessage.value = '';
  }
}

