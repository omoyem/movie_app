import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';

import '../../../utils/helpers.dart';
import 'package:godly_seed_app/view/movie/controller/movie_controller.dart';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'dart:async';
import 'package:godly_seed_app/view/home/controller/home_controller.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String movieTitle;
  final String videoUrl;

  const VideoPlayerScreen({
    Key? key,
    required this.movieTitle,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PodPlayerController _controller;
  VoidCallback? _videoStateListener;
  bool _hasSavedOnPlay = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation on open
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Determine if videoUrl is a file path or network URL
    if (File(widget.videoUrl).existsSync()) {
      _controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.file(File(widget.videoUrl)),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: true,
          isLooping: false,
          videoQualityPriority: [720, 360],
        ),
      )..initialise();
    } else {
      _controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(
          widget.videoUrl,
        ),
        podPlayerConfig: const PodPlayerConfig(
          autoPlay: true,
          isLooping: false,
          videoQualityPriority: [720, 360],
        ),
      )..initialise();
    }

    _videoStateListener = () {
      if (_controller.videoState == PodVideoState.playing && !_hasSavedOnPlay) {
        _hasSavedOnPlay = true;
        _saveProgressOnPlay();
      }
    };
    _controller.addListener(_videoStateListener!);
  }

  @override
  void dispose() {
    if (_videoStateListener != null) {
      _controller.removeListener(_videoStateListener!);
    }
    _saveProgressOnDispose();
    _controller.dispose();
    // Reset orientation when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // Enter fullscreen landscape mode
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Exit fullscreen, return to portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _saveProgressOnDispose() async {
    try {
      final user = await LocalStorageHelper().getUser();
      final profile = await LocalStorageHelper().getProfile();
      if (user == null || profile == null || user.email == null) return;

      String? movieId;
      if (Get.arguments != null && Get.arguments is Map && Get.arguments['movieId'] != null) {
        movieId = Get.arguments['movieId'].toString();
      } else {
        movieId = null; 
      }
      if (movieId == null) return;

      final currentWatchTime = _controller.currentVideoPosition.inSeconds.toString();
      final watchDuration = _controller.totalVideoLength.inSeconds.toString();
      final watchedAt = DateTime.now().toString().substring(0, 19);

      final movieController = Get.isRegistered<MovieController>()
          ? Get.find<MovieController>()
          : Get.put(MovieController());

      await movieController.saveWatchProgress(
        userId: user.email.toString(),
        profileId: profile.id ?? '',
        movieId: movieId,
        currentWatchTime: currentWatchTime,
        watchDuration: watchDuration,
        watchedAt: watchedAt,
      );

      // Trigger continue watching refresh
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.loadContinueWatchingFromApi();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveProgressOnPlay() async {
    try {
      final user = await LocalStorageHelper().getUser();
      final profile = await LocalStorageHelper().getProfile();
      if (user == null || profile == null || user.email == null) return;

      String? movieId;
      if (Get.arguments != null && Get.arguments is Map && Get.arguments['movieId'] != null) {
        movieId = Get.arguments['movieId'].toString();
      } else {
        movieId = null;
      }
      if (movieId == null) return;

      final currentWatchTime = _controller.currentVideoPosition.inSeconds.toString();
      final watchDuration = _controller.totalVideoLength.inSeconds.toString();
      final watchedAt = DateTime.now().toString().substring(0, 19);

      final movieController = Get.isRegistered<MovieController>()
          ? Get.find<MovieController>()
          : Get.put(MovieController());

      await movieController.saveWatchProgress(
        userId: user.email.toString(),
        profileId: profile.id ?? '',
        movieId: movieId,
        currentWatchTime: currentWatchTime,
        watchDuration: watchDuration,
        watchedAt: watchedAt,
      );

      // Trigger continue watching refresh
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.loadContinueWatchingFromApi();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            PodVideoPlayer(controller: _controller),
            // Fullscreen toggle button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: _toggleFullscreen,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.movieTitle,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Video player section
          Expanded(
            flex: 3,
            child: _buildVideoPlayer(),
          ),
          
          // Movie info section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movieTitle,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFFBE0B),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen video player
          Center(
            child: _buildVideoPlayer(),
          ),
          
          // Back button in landscape
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                _toggleFullscreen();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // Movie title in landscape
          Positioned(
            top: 40,
            left: 80,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                widget.movieTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_isFullscreen || orientation == Orientation.landscape) {
          return _buildLandscapeLayout();
        } else {
          return _buildPortraitLayout();
        }
      },
    );
  }
}