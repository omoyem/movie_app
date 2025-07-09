import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/utils/helpers.dart';
import 'package:godly_seed_app/utils/local_storage_service.dart';
import 'package:godly_seed_app/view/login/models/login_response.dart';
import 'package:godly_seed_app/view/favourites/models/get_favourites_request.dart';
import 'package:godly_seed_app/view/sign_up/controller/signup_controller.dart';
import 'package:http/http.dart' as http;

import '../../../data/local/secure_storage_helper.dart';
import '../../../network/api_client.dart';
import '../models/get_favourite_response.dart' as gf;

class GetFavouriteController extends GetxController {
  
  SignupController get _signupController => Get.find<SignupController>();

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);
  LocalStorageHelper _storageHelper = LocalStorageHelper();

  final RxBool isLoading = false.obs;
  final RxBool isAdded = false.obs;

  RxList<gf.Data> favourites = <gf.Data>[].obs;

  final Rx<Profiles> profile = Profiles().obs;
  final Rx<Data> user = Data().obs;

  @override
  void onInit() {
    super.onInit();

  }



  Future<void> getFavourites() async {
    try {
      isLoading.value = true;
      
      if (kDebugMode) {
        print('=== FORGOT PASSWORD REQUEST ===');
        // print('Email: $movieId');
        print('URL: ${Endpoints.baseUrl}${Endpoints.forgotPassword}');
      }

      favourites.clear();

      GetFavouritesRequest request = GetFavouritesRequest(
        profileId: profile.value.id,
        userId: user.value.email
      );

      http.Response response = await apiClient.postRequest(url: Endpoints.getFavourites, data: request.toJson());

      // if(response.body == null){
      //   showSnackBar(title: "Error", message: "Network Error. Kindly check your internet connection", type: 'error');
      //   return;
      // }
      var myResponse = gf.GetFavouriteResponse.fromJson(json.decode(response.body));

      logItem("I am jer again");
      logItem(response.body);

      if(response.statusCode == 200){
        var myResponse = gf.GetFavouriteResponse.fromJson(json.decode(response.body));
        favourites.value = gf.GetFavouriteResponse.fromJson(json.decode(response.body)).data!;

      } else {
        final responseMessage = myResponse.responseMessage ?? 'Failed to send password reset link';

        showSnackBar(title: "Error", message: responseMessage, type: "error");
      }
    } catch (e) {

      logItem(e.toString());

      // _signupController.handleNetworkError(e, Endpoints.forgotPassword);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRememberMe(bool? value) {
    _signupController.toggleRememberMe(value);
  }

  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      _signupController.user.value = null;
      _signupController.accessToken.value = '';
      _signupController.isRememberMe.value = false;
      
      if (kDebugMode) {
        print('Logout successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: ${e.toString()}');
      }
    }
  }

  bool get isRememberMe => _signupController.isRememberMe.value;
  bool get isLoggedIn => _signupController.isLoggedIn;
}