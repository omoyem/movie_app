
import 'package:movie_app/data/models/movie_list_response.dart';

class SearchResult {
  final String id;
  final String title;
  final String description;
  final String? coverPhotoPath;
  final String duration;
  final String? filePath;
  final String? ageGroup;
  final String? tags;
  final String? releaseDate;
  final String views;
  final String rating;

  SearchResult({
    required this.id,
    required this.title,
    required this.description,
    this.coverPhotoPath,
    required this.duration,
    this.filePath,
    this.ageGroup,
    this.tags,
    this.releaseDate,
    required this.views,
    required this.rating,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverPhotoPath: json['cover_photo_path'],
      duration: json['duration'] ?? '0',
      filePath: json['file_path'],
      ageGroup: json['age_group'],
      tags: json['tags'],
      releaseDate: json['release_date'],
      views: json['views'] ?? '0',
      rating: json['rating'] ?? '0',
    );
  }

  
  Movies toMovies() {
    return Movies(
      id: id,
      title: title,
      description: description,
      coverPhotoPath: coverPhotoPath,
      duration: duration,
      filePath: filePath,
      ageGroup: ageGroup,
      tags: tags,
      releaseDate: releaseDate,
      
    );
  }
}


class SearchResponse {
  final int responseCode;
  final String responseMessage;
  final List<SearchResult> data;

  SearchResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      responseCode: json['response_code'] ?? 0,
      responseMessage: json['response_message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => SearchResult.fromJson(item))
          .toList(),
    );
  }
}

