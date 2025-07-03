import 'package:get/get.dart';
import 'package:godly_seed_app/view/login/controller/login_controller.dart';
import 'package:godly_seed_app/view/sign_up/controller/signup_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignupController>(() => SignupController());
  }
}