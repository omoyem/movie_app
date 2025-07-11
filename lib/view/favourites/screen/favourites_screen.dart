import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/utils/helpers.dart';
import 'package:godly_seed_app/view/favourites/controllers/delete_favourite_controller.dart';
import 'package:godly_seed_app/view/favourites/controllers/get_favourite_controller.dart';
import 'package:godly_seed_app/view/home/controller/home_controller.dart';
import 'package:godly_seed_app/view/widgets/big_app_text.dart';
import 'package:godly_seed_app/view/widgets/custom_container_widget.dart';
import 'package:godly_seed_app/view/widgets/no_result_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/local/secure_storage_helper.dart';
import '../../sign_up/controller/signup_controller.dart';
import '../models/get_favourite_response.dart' as gf;
import 'package:godly_seed_app/data/models/movie_list_response.dart' as ml;

class CategoryType {
  String title;
  int id;
  bool? isSelected;

  CategoryType(
      {required this.title, required this.id, this.isSelected = false});
}

class FavouritesScreen extends StatefulWidget {
  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  GetFavouriteController _favouriteController =
      Get.put(GetFavouriteController());
  DeleteFavouriteController _deleteFavouriteController =
      Get.put(DeleteFavouriteController());
  HomeController _homeController = Get.put(HomeController());
  LocalStorageHelper _storageHelper = LocalStorageHelper();

  @override
  void initState() {
    super.initState();

    _favouriteController.isLoading.value = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fetchedUser = await _storageHelper.getUser();
      final fetchedProfile = await _storageHelper.getProfile();
      _favouriteController.user.value = fetchedUser!;
      _favouriteController.profile.value = fetchedProfile!;

      await _favouriteController.getFavourites();
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
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              IconButton(
                icon: Icon(Icons.delete_forever_outlined),
                onPressed: () {},
              )
            ],
          ),
          Skeletonizer(
            enabled: _favouriteController.isLoading.value,
            child: ListView.separated(
              padding: EdgeInsets.only(left: 16),
              shrinkWrap: true,
              itemCount: _favouriteController.isLoading.value
                  ? 5
                  : _favouriteController.favourites.length,
              itemBuilder: (context, index) {
                final movie = _favouriteController.isLoading.value
                    ? null
                    : _favouriteController.favourites[index];
                return _buildMovieCard(movie: movie);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
            ),
          ),
          if (!_favouriteController.isLoading.value &&
              _favouriteController.favourites.isEmpty)
            Center(child: NoResultWidget(title: "No items found")),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMovieCard({gf.Data? movie}) {
    return GestureDetector(
      onTap: () {
        if (movie != null) {
          ml.Movies myMovie = ml.Movies(
            title: movie.title,
            id: movie.id,
            duration: movie.duration,
            description: movie.description,
            ageGroup: movie.ageGroup,
            categoryId: movie.categoryId,
            coverPhotoPath: movie.coverPhotoPath,
            filePath: movie.filePath,
            releaseDate: movie.releaseDate,
            tags: movie.tags,
            uploadedAt: movie.uploadedAt,
          );
          _homeController.navigateToMovieDetails(myMovie);
        }
      },
      child: Row(
        children: [
          Container(
            height: 80,
            width: 120,
            decoration: BoxDecoration(
              color: movie == null ? kLightTextColor.withOpacity(0.3) : null,
              borderRadius: BorderRadius.circular(8),
              image: movie == null ||
                      movie.coverPhotoPath == null ||
                      movie.coverPhotoPath!.isEmpty
                  ? null
                  : DecorationImage(
                      image: NetworkImage(
                          Endpoints.imageBaseUrl + movie.coverPhotoPath!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  movie?.title ?? "Movie Title",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    BigAppText(
                      text: movie == null
                          ? "2005"
                          : extractYear(movie.releaseDate!),
                      size: 12,
                      color: kLightTextColor,
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 8),
          CustomContainer(
            child: Column(children: [
              // If still loading, show spinner
              if (movie?.isLoading ?? false)
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SpinKitCircle(color: primaryColor, size: 20),
                )

              // Otherwise show delete button
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: IconButton(
                    onPressed: () {
                      if(movie != null) {
                        _deleteFavouriteController.deleteFromFavourite(movie.id!);
                      }
                    },
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: primaryColor,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    // keeps it compact
                    constraints: const BoxConstraints(),
                  ),
                )
            ]),
          )
        ],
      ),
    );
  }
}
