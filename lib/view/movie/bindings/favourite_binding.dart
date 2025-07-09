import 'package:get/get.dart';
import 'package:godly_seed_app/view/favourites/controllers/get_favourite_controller.dart';
import 'package:godly_seed_app/view/movie/controller/movie_controller.dart';

class FavouriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetFavouriteController>(() => GetFavouriteController());
  }
}