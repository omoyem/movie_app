import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_app/constants/endpoints.dart';
import 'package:movie_app/utils/helpers.dart';
import 'package:movie_app/utils/local_storage_service.dart';
import 'package:movie_app/view/login/models/login_response.dart';
import 'package:movie_app/view/favourites/models/get_favourites_request.dart';
import 'package:movie_app/view/sign_up/controller/signup_controller.dart';
import 'package:http/http.dart' as http;

import '../../../data/local/secure_storage_helper.dart';
import '../../../network/api_client.dart';
import '../../profile_setup/model/profile_response.dart';
import '../models/category_response.dart' as gf;

class GetCategoriesController extends GetxController {
  
  SignupController get _signupController => Get.find<SignupController>();

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);
  LocalStorageHelper _storageHelper = LocalStorageHelper();

  final RxBool isLoading = false.obs;
  final RxBool isAdded = false.obs;

  RxList<gf.Data> categories = <gf.Data>[].obs;

  final Rx<UserProfile> profile = UserProfile().obs;
  final Rx<Data> user = Data().obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true;

      categories.clear();


      http.Response response = await apiClient.getRequest(url: Endpoints.movieCategories);
      isLoading.value = false;

      // if(response.body == null){
      //   showSnackBar(title: "Error", message: "Network Error. Kindly check your internet connection", type: 'error');
      //   return;
      // }
      var myResponse = gf.CategoryResponse.fromJson(json.decode(response.body));

      logItem("I am categoryyyyyy  again");
      logItem(response.body);

      if(response.statusCode == 200){
        var myResponse = gf.CategoryResponse.fromJson(json.decode(response.body));
        categories.value = gf.CategoryResponse.fromJson(json.decode(response.body)).data!;

      } else {
        final responseMessage = myResponse.responseMessage ?? 'Failed to send password reset link';

        showSnackBar(title: "Error", message: responseMessage, type: "error");
      }
    } catch (e) {

      logItem(e.toString());
      isLoading.value = false;

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