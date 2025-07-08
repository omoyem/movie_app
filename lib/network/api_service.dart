import 'dart:convert';
import 'dart:io';
import 'package:godly_seed_app/data/local/secure_storage_helper.dart';
import 'package:godly_seed_app/utils/httpClient_helper.dart';
import 'package:godly_seed_app/data/models/movie.dart';


class MovieApiService {
  final LocalStorageHelper _storageHelper = LocalStorageHelper();
 static const String baseUrl = 'https://www.godlyseed.accessng.com/api/';



  static HttpClient _createInsecureHttpClient() {
    return InsecureHttpClientHelper.createInsecureHttpClient();
  }
  static Future<MoviesResponse> getMovies({
  required String userId,
  required String profileId,
  int page = 1,
  int perPage = 10,
}) async {
  try {
    final token = await LocalStorageHelper.getAccessTokenMain();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    final requestBody = {
      "user_id": userId,
      "profile_id": profileId,
      "page": page,
      "per_page": perPage,
    };

    final client = _createInsecureHttpClient();
    final uri = Uri.parse('$baseUrl/get_movies');
    final request = await client.postUrl(uri);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

    request.add(utf8.encode(jsonEncode(requestBody)));

    final response = await request.close();

    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseBody);
      return MoviesResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching movies: $e');
  }
}

  
}


class MoviesResponse {
  final int responseCode;
  final String responseMessage;
  final MoviesData data;
  
  MoviesResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.data,
  });
  
  factory MoviesResponse.fromJson(Map<String, dynamic> json) {
    return MoviesResponse(
      responseCode: json['response_code'],
      responseMessage: json['response_message'],
      data: MoviesData.fromJson(json['data']),
    );
  }
}

class MoviesData {
  final List<ApiMovieModel> movies;
  final String ageGroup;
  final List<String> allowedRatings;
  final PaginationModel pagination;
  
  MoviesData({
    required this.movies,
    required this.ageGroup,
    required this.allowedRatings,
    required this.pagination,
  });
  
  factory MoviesData.fromJson(Map<String, dynamic> json) {
    return MoviesData(
      movies: (json['movies'] as List)
          .map((movie) => ApiMovieModel.fromJson(movie))
          .toList(),
      ageGroup: json['age_group'] ?? '',
      allowedRatings: List<String>.from(json['allowed_ratings'] ?? []),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }
}

class ApiMovieModel {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String filePath;
  final String coverPhotoPath;
  final String tags;
  final String ageGroup;
  final String categoryId;
  final String releaseDate;
  final String uploadedAt;
  final String uploadedBy;
  
  ApiMovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.filePath,
    required this.coverPhotoPath,
    required this.tags,
    required this.ageGroup,
    required this.categoryId,
    required this.releaseDate,
    required this.uploadedAt,
    required this.uploadedBy,
  });
  
  factory ApiMovieModel.fromJson(Map<String, dynamic> json) {
    return ApiMovieModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration']?.toString() ?? '',
      filePath: json['file_path'] ?? '',
      coverPhotoPath: json['cover_photo_path'] ?? '',
      tags: json['tags'] ?? '',
      ageGroup: json['age_group'] ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      releaseDate: json['release_date'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
    );
  }
  
  
  MovieModel toMovieModel() {
    
    List<String> categories = [];
    try {
      if (tags.isNotEmpty) {
        final tagsList = json.decode(tags) as List;
        categories = tagsList.map((tag) => tag['value'].toString()).toList();
      }
    } catch (e) {
      categories = ['General'];
    }
    
    return MovieModel(
      id: int.tryParse(id) ?? 0,
      title: title,
      year: releaseDate.split('-').first, 
      seasons: '1 season', 
      imageUrl: coverPhotoPath,
      description: description,
      categories: categories,
      episodes: [], fileUrl: '', 
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int perPage;
  
  PaginationModel({
    required this.currentPage,
    required this.perPage,
  });
  
  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
    );
  }
}