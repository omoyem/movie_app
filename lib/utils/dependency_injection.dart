import 'package:get/get.dart';
import 'package:godly_seed_app/controllers/connection_manager_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<ConnectionManagerController>(ConnectionManagerController(),
        permanent: true);
  }
}
