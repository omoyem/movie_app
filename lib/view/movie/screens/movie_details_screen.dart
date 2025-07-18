import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/app_router.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/constants/endpoints.dart';
import 'package:godly_seed_app/data/models/movie.dart';
import 'package:godly_seed_app/data/models/movie_list_response.dart';
import 'package:godly_seed_app/view/movie/controller/add_favourite_controller.dart';
import 'package:godly_seed_app/view/movie/controller/movie_controller.dart';
import 'package:godly_seed_app/view/widgets/big_app_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../utils/helpers.dart';
import 'package:godly_seed_app/view/downloads/controller/downloads_controller.dart';

class MovieDetailsScreen extends GetView<MovieController> {
  final AddFavouriteController addFavouriteController =
      Get.put(AddFavouriteController());

  final DownloadsController downloadsController = Get.put(DownloadsController());

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
                image: NetworkImage(
                    Endpoints.imageBaseUrl + movie.coverPhotoPath!),
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
                    controller.playMovie();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Release Date: ${extractYear(movie.releaseDate!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 18, color: Colors.amber),
                  BigAppText(text: "4", size: 13),
                ],
              ),
            ],
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
            child: OutlinedButton(
              onPressed: () => addFavouriteController.addToFavourite(
                  controller.currentMovie.value!.id!.toString()),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      addFavouriteController.isLoading.value
                          ? const SpinKitCircle(
                              color: primaryColor,
                              size: 25,
                            )
                          : Icon(controller.currentMovie.value!.isFavourite ?? false
                              ? Icons.check
                              : Icons.add),
                      SizedBox(width: 8),
                      Text(addFavouriteController.isLoading.value
                          ? 'Adding...'
                          : 'My List'),
                    ],
                  ),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _handleDownload,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.download,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload() async {
    final movie = controller.currentMovie.value;
    if (movie == null) {
      _showErrorSnackbar('Movie not found');
      return;
    }

    try {
      bool permissionGranted = true;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        print('[DEBUG] Android SDK version:  [${androidInfo.version.sdkInt}]');
        if (androidInfo.version.sdkInt >= 33) {
        
          PermissionStatus videoStatus = await Permission.videos.status;
          print('[DEBUG] Permission.videos status:  [${videoStatus}]');
          if (!videoStatus.isGranted) {
            videoStatus = await Permission.videos.request();
            print('[DEBUG] Permission.videos request result:  [${videoStatus}]');
          }
          permissionGranted = videoStatus.isGranted;
        } else {
         
          PermissionStatus storageStatus = await Permission.storage.status;
          print('[DEBUG] Permission.storage status:  [${storageStatus}]');
          if (!storageStatus.isGranted) {
            storageStatus = await Permission.storage.request();
            print('[DEBUG] Permission.storage request result:  [${storageStatus}]');
          }
          permissionGranted = storageStatus.isGranted;
        }
      } else {
        print('[DEBUG] Not Android, permission granted by default.');
      }
      if (!permissionGranted) {
        _showWarningSnackbar('Storage permission denied. Download cancelled.');
        _navigateToDownloadScreen();
        return;
      }
      _showInfoSnackbar('Permission granted! Starting download...');
      await _proceedWithDownload(movie);
    } catch (e) {
      _showErrorSnackbar('Permission error: ${e.toString()}');
      _navigateToDownloadScreen();
    }
  }  
 Future<void> _proceedWithDownload(Movies movie) async {
    try {
  
      if (movie.filePath == null || movie.filePath!.isEmpty) {
        _showErrorSnackbar('No download link available for this movie');
        _navigateToDownloadScreen();
        return;
      }

  
      final videoUrl = movie.filePath!.startsWith('http')
          ? movie.filePath!
          : Endpoints.baseUrl + movie.filePath!;
          
      final thumbnailUrl = movie.coverPhotoPath != null
          ? (movie.coverPhotoPath!.startsWith('http')
              ? movie.coverPhotoPath!
              : Endpoints.imageBaseUrl + movie.coverPhotoPath!)
          : null;

     
      await downloadsController.addDownload(
        title: movie.title ?? 'Untitled Movie',
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        details: movie.duration ?? 'Unknown duration',
      );

   
      _showSuccessSnackbar('Download started for "${movie.title ?? 'video'}"');
      
      
      _navigateToDownloadScreen();
      
    } catch (e) {
      _showErrorSnackbar('Failed to start download: ${e.toString()}');
      _navigateToDownloadScreen();
    }
  }


  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Storage permission is required to download movies.'),
            SizedBox(height: 8),
            Text('Please enable it in app settings to continue downloading.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToDownloadScreen();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
              _navigateToDownloadScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }


  void _navigateToDownloadScreen() {
    try {
      AppRouter.toDownload();
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }


  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.white),
    );
  }

 
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.error, color: Colors.white),
    );
  }

  /// Show warning snackbar
  void _showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Show info snackbar
  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primaryColor,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      icon: Icon(Icons.info, color: Colors.white),
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
            movie.description ??
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam commodo elit molestibus nec ex. Lorem urna cursus maximus urna vitae porta viverra turpis venenatis vitae. Ut et ultrices efficitur massa ipsum porta nec. In consectetur facilisis. Morbi ex.',
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
          GestureDetector(
            onTap: () => _handleDownload(),
            child: Icon(
              Icons.download,
              color: Colors.grey[400],
              size: 20,
            ),
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
        // Update current movie and navigate
        controller.currentMovie.value = Movies(
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
        );
        
        Get.to(() => MovieDetailsScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(movie.imageUrl),
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
                movie.title,
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
}