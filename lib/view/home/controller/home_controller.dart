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
    if (args != null && args is Map && args['profile_id'] != null) {
      profileId.value = args['profile_id'].toString();
      if (kDebugMode) {
        print('HomeController: Received profile_id from arguments: \\${profileId.value}');
      }
    }
    loadUserName();
   
  }

  Future<void> loadUserName() async {
    try {
      User? user = await StorageService.getUser();
      if (user != null && user.fullName.isNotEmpty) {
        username.value = user.fullName;

        userId.value = user.email;
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

    final requestBody = {
      "user_id": userId,
      "profile_id": profileId,
      "page": page,
      "per_page": perPage,
    };

    final uri = Uri.parse(Endpoints.baseUrl + Endpoints.getMovies);
    final client = IOClient(InsecureHttpClientHelper.createInsecureHttpClient());
    try {
      final response = await client.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode(requestBody),
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
 
    featuredMovies.value = [
      MovieModel(
        id: 1,
        title: 'Little Angel',
        year: '2022',
        seasons: '3 seasons',
        imageUrl: movie1,
        description: 'Fun and educational content for kids',
        categories: ['Kids', 'Educational'],
        episodes: [
          EpisodeModel(
            id: 1,
            title: 'Pilot',
            description: 'On an island of haves and have-nots, teen John B enlists his three best friends to hunt a legendary treasure linked to his father\'s disappearance.',
            imageUrl: movie2,
            duration: '24 min',
          ),
          EpisodeModel(
            id: 2,
            title: 'The Pilot',
            description: 'On an island of haves and have-nots, teen John B enlists his three best friends to hunt a legendary treasure linked to his father\'s disappearance.',
            imageUrl: movie3,
            duration: '28 min',
          ),
        ],
      ),
   
    ];

    topMovies.value = [
      MovieModel(
        id: 3,
        title: 'Jesus for Kids',
        year: '2021',
        seasons: '2 seasons',
        imageUrl: movie3,
        description: 'Biblical stories for children',
        categories: ['Kids', 'Bible Story'],
        episodes: [],
      ),
    
    ];

    continueWatching.value = [
      MovieModel(
        id: 6,
        title: 'Evan Almighty',
        year: '2007',
        seasons: '1 season',
        imageUrl: movie3,
        description: 'Comedy about modern-day Noah',
        categories: ['Comedy', 'Family'],
        episodes: [],
      ),
     
    ];
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

