
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
        } else {
          similarMovies.clear();
        }
      } else {
        similarMovies.clear();
      }
    } catch (e) {
      similarMovies.clear();
      print('Error loading similar movies: ' + e.toString());
    }
  }

  void toggleMyList() {

    isInMyList.value = !isInMyList.value;


  }

  void playMovie() {
    logItem('You need to subscribe to proceed', title:  '${currentMovie.value?.filePath} ');

    Get.to(()=> VideoPlayerScreen( movieTitle: currentMovie.value!.title!, videoUrl: currentMovie.value!.filePath!));
  }
}
