import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:movie_app/constants/app_router.dart';
import 'package:movie_app/data/local/secure_storage_helper.dart';
import 'package:movie_app/data/models/movie_list_response.dart' as ml;
import 'package:movie_app/network/api_client.dart';
import 'package:movie_app/utils/helpers.dart';
import 'package:movie_app/view/home/movie_request.dart';
import 'package:movie_app/view/login/models/login_response.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:movie_app/constants/endpoints.dart';

import '../../profile_setup/model/profile_response.dart';
import '../models/category_response.dart' as gf;
import 'get_categories_controller.dart';


class HomeController extends GetxController {
  final RxList<ml.Movies> featuredMovies = <ml.Movies>[].obs;
  final RxList<ml.Movies> topMovies = <ml.Movies>[].obs;
  final RxList<ml.Movies> movies = <ml.Movies>[].obs;
  final RxList<ml.Movies> continueWatching = <ml.Movies>[].obs;

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);
  final RxString searchText = ''.obs;
  late RxString username = ''.obs;
  late RxString myToken = ''.obs;
  final RxInt currentCarouselIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Rx<gf.Data> currentCategory = gf.Data().obs;

  final RxString userId = ''.obs;
  final Rx<UserProfile> profile = UserProfile().obs;
  final Rx<Data> user = Data().obs;

  GetCategoriesController _categoriesController =
  Get.put(GetCategoriesController());

  LocalStorageHelper _storageHelper = LocalStorageHelper();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null && args is Map && args['profile'] != null) {
      profile.value = args['profile'];
      username.value = profile.value.name!;
      if (kDebugMode) {
        print('HomeController: Received profile_id from arguments: \\${profile.value.name}');
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetchedUser = await _storageHelper.getUser();
      final fetchedProfile = await _storageHelper.getProfile();

      if (fetchedUser == null || fetchedProfile == null) {
        errorMessage.value = 'User or profile not found. Please log in again.';
        // Optionally, navigate to login screen
        // Get.offAllNamed(AppRouter.login);
        return;
      }

      _categoriesController.getCategories();

      user.value = fetchedUser;
      profile.value = fetchedProfile; 
      username.value = profile.value.name ?? '';
      await loadMoviesFromApi();
      await loadContinueWatchingFromApi();
    });


    // loadUserName();
   
  }

  // Future<void> loadUserName() async {
  //   try {
  //     User? user = await StorageService.getUser();
  //     if (user != null && user.fullName.isNotEmpty) {
  //       username.value = user.fullName;
  //
  //       userId.value = user.email;
  //           }
  //   } catch (e) {
  //     print('Error loading user name: $e');
  //   }
  // }


  Future<void> loadMoviesFromApi() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      logItem(user.value.email!, title: "user email something ");
      logItem(profile.value.id!, title: "profile id something ");

      MovieRequest request = MovieRequest(userId:user.value.email!, profileId: profile.value.id!);


      final response =  await apiClient.postRequest(url: Endpoints.getMovies, data: request.toJson());

      logItem(response.body, title: "my reponse body things");

      isLoading.value = false;

      final myResponse = ml.MovieListResponse.fromJson(json.decode(response.body));

      logItem(myResponse, title: "getting the first response");

      if (myResponse.responseCode == 200) {

        movies.value = ml.MovieListResponse.fromJson(json.decode(response.body)).data!.movies!;

        if (movies.isNotEmpty) {
          
          featuredMovies.value = movies.take(5).toList();

          // Show at least 5 top movies if available
          topMovies.value = movies.length > 5
              ? movies.skip(5).take(5).toList()
              : movies;

          // continueWatching.value = movies.take(3).toList(); 
        }
      } else {
        isLoading.value = false;
        throw Exception(myResponse.responseMessage);
      }
    } catch (e) {
      isLoading.value = false;
      print('Error loading movies from API: $e');
      errorMessage.value = 'Failed to load movies: ${e.toString()}';
      
      loadFallbackMovies();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadContinueWatchingFromApi() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final requestBody = {
        'user_id': user.value.email,
        'profile_id': profile.value.id,
      };

      final response = await apiClient.postRequest(
        url: Endpoints.continueWatching,
        data: requestBody,
      );

      isLoading.value = false;

      final decoded = json.decode(response.body);
      if (decoded['response_code'] == 200 && decoded['data'] != null) {
        continueWatching.value = List<ml.Movies>.from(
          (decoded['data'] as List).map((item) => ml.Movies.fromJson(item)),
        );
      } else {
        throw Exception(decoded['response_message'] ?? 'Unknown error');
      }
    } catch (e) {
      isLoading.value = false;
      print('Error loading continue watching from API: $e');
      errorMessage.value = 'Failed to load continue watching: ${e.toString()}';
      continueWatching.clear();
    } finally {
      isLoading.value = false;
    }
  }


  void loadFallbackMovies() {
    // No fallback data; the app shows an empty state when loading fails.
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

  void navigateToMovieDetails(ml.Movies movie) {
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

