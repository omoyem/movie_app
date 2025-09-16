import 'package:get/get.dart';
import 'package:godly_seed_app/view/subscription/controller/subscription_controller.dart';


class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}