import 'package:get/get.dart';
import 'package:movie_app/constants/app_router.dart';
import 'package:movie_app/utils/local_storage_service.dart';

class SettingsController extends GetxController {
  

  Future<void> logout() async {
    await StorageService.clearUserData();
    Get.offAllNamed(AppRouter.signin);
  }
}
