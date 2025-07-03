import 'package:get/get.dart';
import 'package:godly_seed_app/view/home/controller/home_controller.dart';


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}