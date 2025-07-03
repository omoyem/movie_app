import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../utils/helpers.dart';

class ConnectionManagerController extends GetxController {
  //0 = No Internet, 1 = WIFI Connected ,2 = Mobile Data Connected.
  var connectionType = 0.obs;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    getConnectivityType();

    _streamSubscription =
        Connectivity().onConnectivityChanged.listen(_updateState);
    // _streamSubscription =
    //     _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> getConnectivityType() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

  
    return _updateState(connectivityResult);
  }

  _updateState(List<ConnectivityResult> result) {
  

    if (result.contains(ConnectivityResult.wifi)) {
      connectionType.value = 1;

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    } else if (result.contains(ConnectivityResult.mobile)) {
      connectionType.value = 2;

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    } else if (result.contains(ConnectivityResult.none)) {
      connectionType.value = 0;

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    } else {
      showSnackBar(
          title: 'Error',
          message: 'Failed to get connection type',
          type: 'danger');
    }

   
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
  }
}
