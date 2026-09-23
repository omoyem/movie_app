import 'package:get/get.dart';
import 'package:movie_app/view/movie/controller/movie_controller.dart';

class MovieBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieController>(() => MovieController());
  }
}