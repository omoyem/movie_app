import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_app/constants/endpoints.dart';
import 'package:movie_app/data/models/base_response.dart';
import 'package:movie_app/utils/helpers.dart';
import 'package:movie_app/view/login/models/login_response.dart';
import 'package:movie_app/view/sign_up/controller/signup_controller.dart';
import 'package:http/http.dart' as http;

import '../../../data/local/secure_storage_helper.dart';
import '../../../network/api_client.dart';
import '../../movie/models/add_favourite_request.dart';
import '../../profile_setup/model/profile_response.dart';
import 'get_favourite_controller.dart';

class DeleteFavouriteController extends GetxController {

  final GetFavouriteController _getFavouritesController = Get.put(GetFavouriteController());

  ApiClient apiClient = ApiClient(appbaseurl: Endpoints.baseUrl);
  LocalStorageHelper _storageHelper = LocalStorageHelper();



  final RxBool isLoading = false.obs;
  final RxBool isAdded = false.obs;

  final Rx<UserProfile> profile = UserProfile().obs;
  final Rx<Data> user = Data().obs;

  @override
  void onInit() {
    super.onInit();
   
    if (!Get.isRegistered<SignupController>()) {
      Get.put(SignupController());
    }


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetchedUser = await _storageHelper.getUser();
      final fetchedProfile = await _storageHelper.getProfile();

      // if (fetchedUser == null || fetchedProfile == null) {
      //   errorMessage.value = 'User or profile not found. Please log in again.';
      //   // Optionally, navigate to login screen
      //   // Get.offAllNamed(AppRouter.login);
      //   return;
      // }

      user.value = fetchedUser!;
      profile.value = fetchedProfile!;
    });

  }



  Future<void> deleteFromFavourite(String movieId) async {
    try {
      isLoading.value = true;

      AddFavouriteRequest request = AddFavouriteRequest(
        profileId: profile.value.id,
        userId: user.value.email,
        movieId:movieId
      );
      var selectedFavouriteIndex = _getFavouritesController.favourites.indexWhere((element) => movieId == element.id);

      var selectedFavourite = _getFavouritesController.favourites[selectedFavouriteIndex];

      selectedFavourite.isLoading = true;

      _getFavouritesController.favourites[selectedFavouriteIndex] = selectedFavourite;

      http.Response response = await apiClient.postRequest(url: Endpoints.deleteFavourite, data: request.toJson());

      // if(response.body == null){
      //   showSnackBar(title: "Error", message: "Network Error. Kindly check your internet connection", type: 'error');
      //   return;
      // }

      logItem("I am jer again");
      logItem(response.body);
      var result = BaseResponse.fromJson(json.decode(response.body));

      if(result.responseCode == 200){
        final responseMessage = result.responseMessage ?? 'Add to my list successfully';

        await Future.delayed(Duration(milliseconds: 100), (){
          showSnackBar(title: "Success", message: responseMessage, type: "success");
        });

        await _getFavouritesController.getFavourites();

      } else {
        final responseMessage = result.responseMessage ?? 'Failed to send password reset link';

        showSnackBar(title: "Error", message: responseMessage, type: "error");
      }
    } catch (e) {

      logItem(e.toString());

      // _getFavouritesController.handleNetworkError(e, Endpoints.forgotPassword);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRememberMe(bool? value) {
    _getFavouritesController.toggleRememberMe(value);
  }

  bool get isLoggedIn => _getFavouritesController.isLoggedIn;
}