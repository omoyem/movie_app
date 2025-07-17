import 'package:get/get.dart';
import 'package:godly_seed_app/view/downloads_screen/controller/downloads_controller.dart';



class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadsController>(() => DownloadsController());
  }
}