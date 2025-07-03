import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/images.dart' as Images;
import 'package:godly_seed_app/data/models/movie.dart';
import 'package:godly_seed_app/view/home/controller/home_controller.dart';
import 'package:godly_seed_app/view/widgets/app_logo_widget.dart';

class HomeScreen extends GetView<HomeController> {
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeaturedCarousel(),
                    _buildCategoryTabs(),
                    _buildTopMoviesSection(),
                    _buildContinueWatchingSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
      
        AppLogoWidget(size: 120),
              
        ],
      ),
    );
  }



  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          onChanged: controller.updateSearchText,
          decoration: InputDecoration(
            hintText: 'Search for movies and lots more',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey),
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
          height: 300,
          viewportFraction: 0.7, 
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
                  image: AssetImage(movie.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: 8),
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
      child: Row(
        children: [
          _buildCategoryTab('Movies', true),
          SizedBox(width: 12),
          _buildCategoryTab('Cartoons', false),
          SizedBox(width: 12),
          _buildCategoryTab('Bible Story', false),
          SizedBox(width: 12),
          _buildCategoryTab('Talking Animals', false),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTopMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Top Movies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16),
            itemCount: controller.topMovies.length,
            itemBuilder: (context, index) {
              final movie = controller.topMovies[index];
              return _buildMovieCard(movie);
            },
          )),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Continue Watching',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16),
            itemCount: controller.continueWatching.length,
            itemBuilder: (context, index) {
              final movie = controller.continueWatching[index];
              return _buildMovieCard(movie, showProgress: true);
            },
          )),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMovieCard(MovieModel movie, {bool showProgress = false}) {
    return GestureDetector(
      onTap: () => controller.navigateToMovieDetails(movie),
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(movie.imageUrl),
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
              ],
            ),
            SizedBox(height: 8),
            Text(
              movie.title,
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

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.search, 'Search', false),
          _buildNavItem(Icons.games, 'Games', false),
          _buildNavItem(Icons.download, 'Downloads', false),
          _buildNavItem(Icons.list, 'My List', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
