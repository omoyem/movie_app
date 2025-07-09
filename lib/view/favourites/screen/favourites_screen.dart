import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/view/favourites/controllers/get_favourite_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/local/secure_storage_helper.dart';
import '../../sign_up/controller/signup_controller.dart';
import '../models/get_favourite_response.dart' as gf;


class CategoryType {
  String title;
  int id;
  bool? isSelected;

  CategoryType({required this.title, required this.id, this.isSelected = false});
}

class FavouritesScreen extends StatefulWidget {

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {


  GetFavouriteController _favouriteController = Get.put(GetFavouriteController());
  LocalStorageHelper _storageHelper = LocalStorageHelper();

  @override
  void initState() {
    super.initState();


    if (!Get.isRegistered<SignupController>()) {
      Get.put(SignupController());
    }


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetchedUser = await _storageHelper.getUser();
      final fetchedProfile = await _storageHelper.getProfile();

      await _favouriteController.getFavourites();

      // if (fetchedUser == null || fetchedProfile == null) {
      //   errorMessage.value = 'User or profile not found. Please log in again.';
      //   // Optionally, navigate to login screen
      //   // Get.offAllNamed(AppRouter.login);
      //   return;
      // }

      _favouriteController. user.value = fetchedUser!;
      _favouriteController. profile.value = fetchedProfile!;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContinueWatchingSection(),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'My List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() => Skeletonizer(
          enabled: _favouriteController.isLoading.value,
          child: ListView.separated(
            padding: EdgeInsets.only(left: 16),
            shrinkWrap: true,
            itemCount: _favouriteController.isLoading.value ? 5 : _favouriteController.favourites.length,
            itemBuilder: (context, index) {
              final movie = _favouriteController.isLoading.value ? null : _favouriteController.favourites[index];
              return _buildMovieCard(movie: movie, showProgress: true);
            }, separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 10);
          },
          ),
        )),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMovieCard({gf.Data? movie, bool showProgress = false}) {
    return GestureDetector(
      onTap: () {
        if(movie != null) {
          // controller.navigateToMovieDetails(movie);
        }},
      child: Row(
        children: [
          Container(
            height: 80,
            width: 130,
            decoration: BoxDecoration(
              color: movie == null ? kLightTextColor.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(8),
              image: movie == null || movie.coverPhotoPath == null || movie.coverPhotoPath!.isEmpty ? null : DecorationImage(
                image: NetworkImage(Endpoints.imageBaseUrl + movie.coverPhotoPath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              movie?.title ?? "Movie Title",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: primaryColor,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          IconButton(onPressed: (){}, icon: Icon(Icons.play_circle_outline, color: primaryColor,))
        ],
      ),
    );
  }
}
