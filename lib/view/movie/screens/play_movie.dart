import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pod_player/pod_player.dart';

import '../../../utils/helpers.dart';

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
  // late final PodPlayerController controller;

  late PodPlayerController _controller;



  @override
  void initState() {
    super.initState();
    // initializePlayer();

    _controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(
          widget.videoUrl,
        ),
        podPlayerConfig: const PodPlayerConfig(
            autoPlay: true,
            isLooping: false,
            videoQualityPriority: [720, 360]))
      ..initialise();
  }

  // void initializePlayer() async {
  //   try {
  //     const videoUrl = 'https://s3.us-east-005.backblazeb2.com/godmov/movies/Discover%20Nigeria.mp4';

  //     controller = PodPlayerController(
  //       playVideoFrom: PlayVideoFrom.network(videoUrl),
  //       podPlayerConfig: const PodPlayerConfig(
  //         autoPlay: true,
  //         isLooping: false,
  //         videoQualityPriority: [720, 360],
  //       ),
  //     )..initialise();

  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error initializing video player: $e');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to load video. Please try again.',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  Column CustomVideoPlayer(
      BuildContext context, PodPlayerController? controller) {
    return Column(
      children: [
        SizedBox(
          width: deviceWidth(context),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PodVideoPlayer(controller: controller!),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          '${widget.movieTitle}',
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
          // Video Player
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: CustomVideoPlayer( context, _controller,
              ),
            ),
          ),

          // Movie Info Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 8),
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
}