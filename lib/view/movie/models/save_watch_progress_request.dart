import 'dart:convert';

class SaveWatchProgressRequest {
  final String userId;
  final String profileId;
  final String movieId;
  final String currentWatchTime;
  final String watchDuration;
  final String watchedAt;

  SaveWatchProgressRequest({
    required this.userId,
    required this.profileId,
    required this.movieId,
    required this.currentWatchTime,
    required this.watchDuration,
    required this.watchedAt,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'profile_id': profileId,
        'movie_id': movieId,
        'current_watch_time': currentWatchTime,
        'watch_duration': watchDuration,
        'watched_at': watchedAt,
      };

  String toRawJson() => json.encode(toJson());

  factory SaveWatchProgressRequest.fromJson(Map<String, dynamic> json) => SaveWatchProgressRequest(
        userId: json['user_id'],
        profileId: json['profile_id'],
        movieId: json['movie_id'],
        currentWatchTime: json['current_watch_time'],
        watchDuration: json['watch_duration'],
        watchedAt: json['watched_at'],
      );
} 