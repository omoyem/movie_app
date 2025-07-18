import 'package:get/get.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'package:godly_seed_app/utils/helpers.dart';
import 'dart:convert';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/network/api_client.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/movie.dart';
import '../screens/play_movie.dart';

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
    logItem('You need to subscribe to proceed', title: '${currentMovie.value?.filePath} ');

  
    Get.to(
      () => VideoPlayerScreen(
        movieTitle: currentMovie.value!.title!, 
        videoUrl: currentMovie.value!.filePath!
      ),
      arguments: {
        'movieId': currentMovie.value!.id!,
        'movieTitle': currentMovie.value!.title!,
        'videoUrl': currentMovie.value!.filePath!,
      },
    );
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
            final responseCode = decodedResponse['response_code'] ?? decodedResponse['status_code'];
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