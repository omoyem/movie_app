import 'dart:convert';
MovieListResponse movieListResponseFromJson(String str) => MovieListResponse.fromJson(json.decode(str));
String movieListResponseToJson(MovieListResponse data) => json.encode(data.toJson());
class MovieListResponse {
  MovieListResponse({
      num? responseCode, 
      String? responseMessage, 
      Data? data,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
    _data = data;
}

  MovieListResponse.fromJson(dynamic json) {
    _responseCode = json['response_code'];
    _responseMessage = json['response_message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  num? _responseCode;
  String? _responseMessage;
  Data? _data;
MovieListResponse copyWith({  num? responseCode,
  String? responseMessage,
  Data? data,
}) => MovieListResponse(  responseCode: responseCode ?? _responseCode,
  responseMessage: responseMessage ?? _responseMessage,
  data: data ?? _data,
);
  num? get responseCode => _responseCode;
  String? get responseMessage => _responseMessage;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['response_code'] = _responseCode;
    map['response_message'] = _responseMessage;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      List<Movies>? movies, 
      String? ageGroup, 
      List<String>? allowedRatings, 
      Pagination? pagination,}){
    _movies = movies;
    _ageGroup = ageGroup;
    _allowedRatings = allowedRatings;
    _pagination = pagination;
}

  Data.fromJson(dynamic json) {
    if (json['movies'] != null) {
      _movies = [];
      json['movies'].forEach((v) {
        _movies?.add(Movies.fromJson(v));
      });
    }
    _ageGroup = json['age_group'];
    _allowedRatings = json['allowed_ratings'] != null ? json['allowed_ratings'].cast<String>() : [];
    _pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }
  List<Movies>? _movies;
  String? _ageGroup;
  List<String>? _allowedRatings;
  Pagination? _pagination;
Data copyWith({  List<Movies>? movies,
  String? ageGroup,
  List<String>? allowedRatings,
  Pagination? pagination,
}) => Data(  movies: movies ?? _movies,
  ageGroup: ageGroup ?? _ageGroup,
  allowedRatings: allowedRatings ?? _allowedRatings,
  pagination: pagination ?? _pagination,
);
  List<Movies>? get movies => _movies;
  String? get ageGroup => _ageGroup;
  List<String>? get allowedRatings => _allowedRatings;
  Pagination? get pagination => _pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_movies != null) {
      map['movies'] = _movies?.map((v) => v.toJson()).toList();
    }
    map['age_group'] = _ageGroup;
    map['allowed_ratings'] = _allowedRatings;
    if (_pagination != null) {
      map['pagination'] = _pagination?.toJson();
    }
    return map;
  }

}

Pagination paginationFromJson(String str) => Pagination.fromJson(json.decode(str));
String paginationToJson(Pagination data) => json.encode(data.toJson());
class Pagination {
  Pagination({
      num? currentPage, 
      num? perPage,}){
    _currentPage = currentPage;
    _perPage = perPage;
}

  Pagination.fromJson(dynamic json) {
    _currentPage = json['current_page'];
    _perPage = json['per_page'];
  }
  num? _currentPage;
  num? _perPage;
Pagination copyWith({  num? currentPage,
  num? perPage,
}) => Pagination(  currentPage: currentPage ?? _currentPage,
  perPage: perPage ?? _perPage,
);
  num? get currentPage => _currentPage;
  num? get perPage => _perPage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = _currentPage;
    map['per_page'] = _perPage;
    return map;
  }

}

Movies moviesFromJson(String str) => Movies.fromJson(json.decode(str));
String moviesToJson(Movies data) => json.encode(data.toJson());
class Movies {
  Movies({
      String? id, 
      String? title, 
      String? description, 
      String? duration, 
      String? filePath, 
      String? coverPhotoPath, 
      String? tags, 
      String? ageGroup, 
      String? categoryId, 
      String? releaseDate, 
      String? uploadedAt, 
      String? uploadedBy,
      bool? isFavourite,
  }){
    _id = id;
    _title = title;
    _description = description;
    _duration = duration;
    _filePath = filePath;
    _coverPhotoPath = coverPhotoPath;
    _tags = tags;
    _ageGroup = ageGroup;
    _categoryId = categoryId;
    _releaseDate = releaseDate;
    _uploadedAt = uploadedAt;
    _uploadedBy = uploadedBy;
    _isFavourite = isFavourite;
}

  Movies.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _duration = json['duration'];
    _filePath = json['file_path'];
    _coverPhotoPath = json['cover_photo_path'];
    _tags = json['tags'];
    _ageGroup = json['age_group'];
    _categoryId = json['category_id'];
    _releaseDate = json['release_date'];
    _uploadedAt = json['uploaded_at'];
    _uploadedBy = json['uploaded_by'];
    _isFavourite = json['is_favorite'];
  }
  String? _id;
  String? _title;
  String? _description;
  String? _duration;
  String? _filePath;
  String? _coverPhotoPath;
  String? _tags;
  String? _ageGroup;
  String? _categoryId;
  String? _releaseDate;
  String? _uploadedAt;
  String? _uploadedBy;
  bool? _isFavourite;


  set isFavourite(bool? value) {
    _isFavourite = value;
  }

  Movies copyWith({  String? id,
  String? title,
  String? description,
  String? duration,
  String? filePath,
  String? coverPhotoPath,
  String? tags,
  String? ageGroup,
  String? categoryId,
  String? releaseDate,
  String? uploadedAt,
  String? uploadedBy,
  bool? isFavourite,
}) => Movies(  id: id ?? _id,
  title: title ?? _title,
  description: description ?? _description,
  duration: duration ?? _duration,
  filePath: filePath ?? _filePath,
  coverPhotoPath: coverPhotoPath ?? _coverPhotoPath,
  tags: tags ?? _tags,
  ageGroup: ageGroup ?? _ageGroup,
  categoryId: categoryId ?? _categoryId,
  releaseDate: releaseDate ?? _releaseDate,
  uploadedAt: uploadedAt ?? _uploadedAt,
  uploadedBy: uploadedBy ?? _uploadedBy,
  isFavourite: isFavourite ?? _isFavourite,
);
  String? get id => _id;
  String? get title => _title;
  String? get description => _description;
  String? get duration => _duration;
  String? get filePath => _filePath;
  String? get coverPhotoPath => _coverPhotoPath;
  String? get tags => _tags;
  String? get ageGroup => _ageGroup;
  String? get categoryId => _categoryId;
  String? get releaseDate => _releaseDate;
  String? get uploadedAt => _uploadedAt;
  String? get uploadedBy => _uploadedBy;
  bool? get isFavourite => _isFavourite;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['duration'] = _duration;
    map['file_path'] = _filePath;
    map['cover_photo_path'] = _coverPhotoPath;
    map['tags'] = _tags;
    map['age_group'] = _ageGroup;
    map['category_id'] = _categoryId;
    map['release_date'] = _releaseDate;
    map['uploaded_at'] = _uploadedAt;
    map['uploaded_by'] = _uploadedBy;
    map['is_favorite'] = _isFavourite;
    return map;
  }

}