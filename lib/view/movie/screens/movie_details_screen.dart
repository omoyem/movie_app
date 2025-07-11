import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/models/movie.dart';
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'package:godly_seed_app/view/movie/controller/add_favourite_controller.dart';
import 'package:godly_seed_app/view/movie/controller/movie_controller.dart';

import '../../../utils/helpers.dart';

class MovieDetailsScreen extends GetView<MovieController> {


  final AddFavouriteController addFavouriteController = Get.put(AddFavouriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final movie = controller.currentMovie.value;
          if (movie == null) return Center(child: CircularProgressIndicator());

          return Column(
            children: [
              _buildHeader(movie),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieInfo(movie),
                      _buildActionButtons(),
                      _buildAboutSection(movie),
                      // _buildEpisodesSection(movie),
                      _buildSimilarMoviesSection(),
                    ],
                  ),
                ),
              ),
              // _buildBottomNavigation(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(Movies movie) {
    return Container(
      height: 250,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(Endpoints.imageBaseUrl + movie.coverPhotoPath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 32,
                  ),
                  onPressed: () {

                  },
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfo(Movies movie) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title ?? "No title",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Release Date: ${extractYear(movie.releaseDate!)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.playMovie,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Obx(() => OutlinedButton(
                  onPressed: () => addFavouriteController.addToFavourite(controller.currentMovie.value!.id!.toString()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      addFavouriteController.isLoading.value ?
                          const SpinKitCircle(color: primaryColor, size: 25,) :
                      Icon(addFavouriteController.isAdded.value
                          ? Icons.check
                          : Icons.add),
                      SizedBox(width: 8),
                      Row(
                        children: [
                          addFavouriteController.isLoading.value ?
                          Text('Adding...') : Text('My List'),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Movies movie) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            movie.description ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam commodo elit molestibus nec ex. Lorem urna cursus maximus urna vitae porta viverra turpis venenatis vitae. Ut et ultrices efficitur massa ipsum porta nec. In consectetur facilisis. Morbi ex.',
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection(MovieModel movie) {
    if (movie.episodes.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                'EPISODES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                'SIMILAR MOVIES',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: movie.episodes
                .map((episode) => _buildEpisodeItem(episode))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeItem(EpisodeModel episode) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(episode.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${episode.id}. ${episode.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  episode.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.download,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Similar Movies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 200,
          child: Obx(() => GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: controller.similarMovies.length,
                itemBuilder: (context, index) {
                  final movie = controller.similarMovies[index];
                  return _buildSimilarMovieCard(movie);
                },
              )),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSimilarMovieCard(MovieModel movie) {
    return GestureDetector(
      onTap: () {
        // Navigate to MovieDetailsScreen with the selected movie's id and details
        Get.to(
          () => MovieDetailsScreen(),
          arguments: Movies(
            id: movie.id.toString(),
            title: movie.title,
            description: movie.description,
            duration: '',
            filePath: movie.fileUrl,
            coverPhotoPath: movie.imageUrl,
            tags: jsonEncode(movie.categories.map((e) => {'value': e}).toList()),
            ageGroup: '',
            categoryId: '',
            releaseDate: movie.year,
            uploadedAt: '',
            uploadedBy: '',
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(movie.imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title ?? "No title",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
          _buildNavItem(Icons.home, 'Home', false),
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
