import 'package:get/get.dart';
import 'package:godly_seed_app/view/profile_setup/controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}