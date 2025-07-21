import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/constants/images.dart' as Images;
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'package:godly_seed_app/view/home/controller/home_controller.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';
import 'package:godly_seed_app/view/widgets/custom_container_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/category_response.dart' as gf;

import '../../../utils/helpers.dart';
import '../controller/get_categories_controller.dart';

class CategoryType {
  String title;
  int id;
  bool? isSelected;

  CategoryType(
      {required this.title, required this.id, this.isSelected = false});
}

class HomeScreen extends GetView<HomeController> {
  GetCategoriesController _categoriesController =
      Get.put(GetCategoriesController());

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadMoviesFromApi();
                  await controller.loadContinueWatchingFromApi();
                  await _categoriesController.getCategories();
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeaturedCarousel(),
                      _buildCategoryTabs(),
                      _buildTopMoviesSection(),
                      Obx(() => controller.continueWatching.isNotEmpty
                          ? _buildContinueWatchingSection()
                          : SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(Images.profileImg),
          ),
          SizedBox(width: 12),
          Obx(() => Text(
                'Hi ${controller.username.value},',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )),
          Spacer(),
          AppLogoWidget(size: 80),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
    child: GestureDetector(
      onTap: () {
        // Navigate to search screen
        Get.toNamed(AppRouter.searchMovies);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              'Search for movies and lots more',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFeaturedCarousel() {
    return Obx(() => Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                viewportFraction: 0.6,
                autoPlay: true,
                enlargeCenterPage: true,
                enlargeFactor: 0.3,
                onPageChanged: (index, reason) {
                  controller.updateCarouselIndex(index);
                },
              ),
              items: controller.featuredMovies.map((movie) {
                return GestureDetector(
                  onTap: () => controller.navigateToMovieDetails(movie),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(
                          movie.coverPhotoPath != null &&
                                  movie.coverPhotoPath!.isNotEmpty
                              ? getImageUrl(movie.coverPhotoPath!)
                              : 'https://via.placeholder.com/300x450?text=No+Image',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: controller.featuredMovies.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.currentCarouselIndex.value == entry.key
                        ? primaryColor
                        : Colors.grey[300],
                  ),
                );
              }).toList(),
            ),
          ],
        ));
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () => CustomContainer(
          height: 60,
          width: double.infinity,
          child: Skeletonizer(
            enabled: _categoriesController.isLoading.value,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: _categoriesController.isLoading.value
                  ? 5
                  : _categoriesController.categories.length,
              itemBuilder: (BuildContext context, int index) {
                var category = _categoriesController.isLoading.value
                    ? null
                    : _categoriesController.categories[index];
                return _buildCategoryItem(category);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(gf.Data? category) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: InkWell(
          onTap: () {
            if (category != null) {
              controller.currentCategory.value = category;
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: category == null
                  ? Colors.grey[200]
                  : (controller.currentCategory.value.id == category?.id
                      ? primaryColor
                      : Colors.grey[200]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                category?.name ?? "Category Name",
                style: TextStyle(
                  color: controller.currentCategory.value.id == category?.id
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Top Movies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Obx(() => Skeletonizer(
                enabled: controller.isLoading.value,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 16),
                  itemCount: controller.topMovies.length,
                  itemBuilder: (context, index) {
                    final movie = controller.isLoading.value
                        ? null
                        : controller.topMovies[index];
                    return _buildMovieCard(movie: movie);
                  },
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Continue Watching',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 16),
                itemCount: controller.continueWatching.length > 5 ? 5 : controller.continueWatching.length,
                itemBuilder: (context, index) {
                  final movie = controller.continueWatching[index];
                  return _buildMovieCard(movie: movie, showProgress: true);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildMovieCard({Movies? movie, bool showProgress = false}) {
    return GestureDetector(
      onTap: () {
        if (movie != null) {
          controller.navigateToMovieDetails(movie);
        }
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: movie == null ? kLightTextColor : null,
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
                if (showProgress)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    right: 4,
                    child: LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '5m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                if (movie == null ||
                    movie.coverPhotoPath == null ||
                    movie.coverPhotoPath!.isEmpty)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey[400]),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              movie?.title ?? "Movie Title",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

// Widget _buildBottomNavigation() {
//   return Container(
//     height: 70,
//     decoration: BoxDecoration(
//       color: primaryColor,
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(20),
//         topRight: Radius.circular(20),
//       ),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildNavItem(Icons.home, 'Home', true),
//         _buildNavItem(Icons.search, 'Search', false),
//         _buildNavItem(Icons.games, 'Games', false),
//         _buildNavItem(Icons.download, 'Downloads', false),
//         _buildNavItem(Icons.list, 'My List', false),
//       ],
//     ),
//   );
// }

// Widget _buildNavItem(IconData icon, String label, bool isSelected) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Icon(
//         icon,
//         color: isSelected ? Colors.white : Colors.white70,
//         size: 24,
//       ),
//       SizedBox(height: 4),
//       Text(
//         label,
//         style: TextStyle(
//           color: isSelected ? Colors.white : Colors.white70,
//           fontSize: 10,
//         ),
//       ),
//     ],
//   );
// }
}
