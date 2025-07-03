import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

enum NetworkTimeoutStatus {
  initial,
  networkTimeout,
  networkConnected
}

class EnumX extends GetxController {
  Rx<NetworkTimeoutStatus> myEnum = Rx<NetworkTimeoutStatus>(NetworkTimeoutStatus.initial);
}