
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/images.dart';
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'package:godly_seed_app/utils/helpers.dart';

import '../../../data/models/movie.dart';
import '../screens/play_movie.dart';

class MovieController extends GetxController {
  final Rx<Movies?> currentMovie = Rx<Movies?>(null);
  final RxList<MovieModel> similarMovies = <MovieModel>[].obs;
  final RxBool isInMyList = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentMovie.value = Get.arguments as Movies?;
    loadSimilarMovies();
  }

  void loadSimilarMovies() {
    
    similarMovies.value = [
      MovieModel(
        id: 8,
        title: 'Jesus for Kids',
        year: '2021',
        seasons: '2 seasons',
        imageUrl: movie1,
        description: 'Biblical stories for children',
        categories: ['Kids', 'Bible Story'],
        episodes: [],
      ),
      MovieModel(
        id: 9,
        title: 'Sunday School Musical',
        year: '2020',
        seasons: '1 season',
        imageUrl: movie4,
        description: 'Musical adventures in Sunday school',
        categories: ['Kids', 'Music'],
        episodes: [],
      ),
      MovieModel(
        id: 10,
        title: 'Evan Almighty',
        year: '2007',
        seasons: '1 season',
        imageUrl: movie3,
        description: 'Comedy about modern-day Noah',
        categories: ['Comedy', 'Family'],
        episodes: [],
      ),
      MovieModel(
        id: 11,
        title: 'Step Dogs',
        year: '2013',
        seasons: '1 season',
        imageUrl: movie2,
        description: 'Family comedy about dogs',
        categories: ['Comedy', 'Family'],
        episodes: [],
      ),
      MovieModel(
        id: 12,
        title: 'Letters to God',
        year: '2010',
        seasons: '1 season',
        imageUrl: movie5,
        description: 'Inspirational family drama',
        categories: ['Drama', 'Family'],
        episodes: [],
      ),
      MovieModel(
        id: 13,
        title: 'The Stray',
        year: '2017',
        seasons: '1 season',
        imageUrl: movie1,
        description: 'The story of a loyal dog',
        categories: ['Family', 'Drama'],
        episodes: [],
      ),
    ];
  }

  void toggleMyList() {
    isInMyList.value = !isInMyList.value;
  }

  void playMovie() {
    logItem('You need to subscribe to proceed', title:  '${currentMovie.value?.filePath} ');

    Get.to(()=> VideoPlayerScreen( movieTitle: currentMovie.value!.title!, videoUrl: currentMovie.value!.filePath!));
  }
}
