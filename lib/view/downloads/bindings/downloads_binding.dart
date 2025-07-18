import 'package:get/get.dart';
import 'package:godly_seed_app/view/downloads/controller/downloads_controller.dart';

class DownloadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DownloadsController>(() => DownloadsController());
  }
}