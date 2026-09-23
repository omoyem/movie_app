import 'package:get/get.dart';
import 'package:movie_app/view/search/controller/search_controller.dart';


class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}