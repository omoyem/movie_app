import 'dart:convert';
GetFavouriteResponse getFavouriteResponseFromJson(String str) => GetFavouriteResponse.fromJson(json.decode(str));
String getFavouriteResponseToJson(GetFavouriteResponse data) => json.encode(data.toJson());
class GetFavouriteResponse {
  GetFavouriteResponse({
      num? responseCode, 
      String? responseMessage, 
      List<Data>? data,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
    _data = data;
}

  GetFavouriteResponse.fromJson(dynamic json) {
    _responseCode = json['response_code'];
    _responseMessage = json['response_message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  num? _responseCode;
  String? _responseMessage;
  List<Data>? _data;
GetFavouriteResponse copyWith({  num? responseCode,
  String? responseMessage,
  List<Data>? data,
}) => GetFavouriteResponse(  responseCode: responseCode ?? _responseCode,
  responseMessage: responseMessage ?? _responseMessage,
  data: data ?? _data,
);
  num? get responseCode => _responseCode;
  String? get responseMessage => _responseMessage;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['response_code'] = _responseCode;
    map['response_message'] = _responseMessage;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? id, 
      String? username, 
      String? title, 
      String? description, 
      dynamic slugs, 
      String? duration, 
      String? filePath, 
      dynamic videoFileSize, 
      String? coverPhotoPath, 
      dynamic thumbnailUrl, 
      String? biblicalThemes, 
      String? musicalContent, 
      String? animated, 
      String? educationalContent, 
      String? featured, 
      String? status, 
      dynamic trailerUrl, 
      String? ageGroup, 
      String? tags, 
      String? releaseDate, 
      String? categoryId, 
      String? views, 
      String? rating, 
      dynamic youtubeVideoId, 
      String? uploadedAt,
      bool? isLoading
  }){
    _id = id;
    _username = username;
    _title = title;
    _description = description;
    _slugs = slugs;
    _duration = duration;
    _filePath = filePath;
    _videoFileSize = videoFileSize;
    _coverPhotoPath = coverPhotoPath;
    _thumbnailUrl = thumbnailUrl;
    _biblicalThemes = biblicalThemes;
    _musicalContent = musicalContent;
    _animated = animated;
    _educationalContent = educationalContent;
    _featured = featured;
    _status = status;
    _trailerUrl = trailerUrl;
    _ageGroup = ageGroup;
    _tags = tags;
    _releaseDate = releaseDate;
    _categoryId = categoryId;
    _views = views;
    _rating = rating;
    _youtubeVideoId = youtubeVideoId;
    _uploadedAt = uploadedAt;
    _isLoading = isLoading;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _username = json['username'];
    _title = json['title'];
    _description = json['description'];
    _slugs = json['slugs'];
    _duration = json['duration'];
    _filePath = json['file_path'];
    _videoFileSize = json['video_file_size'];
    _coverPhotoPath = json['cover_photo_path'];
    _thumbnailUrl = json['thumbnail_url'];
    _biblicalThemes = json['biblical_themes'];
    _musicalContent = json['musical_content'];
    _animated = json['animated'];
    _educationalContent = json['educational_content'];
    _featured = json['featured'];
    _status = json['status'];
    _trailerUrl = json['trailer_url'];
    _ageGroup = json['age_group'];
    _tags = json['tags'];
    _releaseDate = json['release_date'];
    _categoryId = json['category_id'];
    _views = json['views'];
    _rating = json['rating'];
    _youtubeVideoId = json['youtube_video_id'];
    _isLoading = false;
  }
  String? _id;
  String? _username;
  String? _title;
  String? _description;
  dynamic _slugs;
  String? _duration;
  String? _filePath;
  dynamic _videoFileSize;
  String? _coverPhotoPath;
  dynamic _thumbnailUrl;
  String? _biblicalThemes;
  String? _musicalContent;
  String? _animated;
  String? _educationalContent;
  String? _featured;
  String? _status;
  dynamic _trailerUrl;
  String? _ageGroup;
  String? _tags;
  String? _releaseDate;
  String? _categoryId;
  String? _views;
  String? _rating;
  dynamic _youtubeVideoId;
  String? _uploadedAt;
  bool? _isLoading;
Data copyWith({  String? id,
  String? username,
  String? title,
  String? description,
  dynamic slugs,
  String? duration,
  String? filePath,
  dynamic videoFileSize,
  String? coverPhotoPath,
  dynamic thumbnailUrl,
  String? biblicalThemes,
  String? musicalContent,
  String? animated,
  String? educationalContent,
  String? featured,
  String? status,
  dynamic trailerUrl,
  String? ageGroup,
  String? tags,
  String? releaseDate,
  String? categoryId,
  String? views,
  String? rating,
  dynamic youtubeVideoId,
  String? uploadedAt,
  bool? isLoading,
}) => Data(  id: id ?? _id,
  username: username ?? _username,
  title: title ?? _title,
  description: description ?? _description,
  slugs: slugs ?? _slugs,
  duration: duration ?? _duration,
  filePath: filePath ?? _filePath,
  videoFileSize: videoFileSize ?? _videoFileSize,
  coverPhotoPath: coverPhotoPath ?? _coverPhotoPath,
  thumbnailUrl: thumbnailUrl ?? _thumbnailUrl,
  biblicalThemes: biblicalThemes ?? _biblicalThemes,
  musicalContent: musicalContent ?? _musicalContent,
  animated: animated ?? _animated,
  educationalContent: educationalContent ?? _educationalContent,
  featured: featured ?? _featured,
  status: status ?? _status,
  trailerUrl: trailerUrl ?? _trailerUrl,
  ageGroup: ageGroup ?? _ageGroup,
  tags: tags ?? _tags,
  releaseDate: releaseDate ?? _releaseDate,
  categoryId: categoryId ?? _categoryId,
  views: views ?? _views,
  rating: rating ?? _rating,
  youtubeVideoId: youtubeVideoId ?? _youtubeVideoId,
  uploadedAt: uploadedAt ?? _uploadedAt,
  isLoading: isLoading ?? _isLoading,
);
  String? get id => _id;
  String? get username => _username;
  String? get title => _title;
  String? get description => _description;
  dynamic get slugs => _slugs;
  String? get duration => _duration;
  String? get filePath => _filePath;
  dynamic get videoFileSize => _videoFileSize;
  String? get coverPhotoPath => _coverPhotoPath;
  dynamic get thumbnailUrl => _thumbnailUrl;
  String? get biblicalThemes => _biblicalThemes;
  String? get musicalContent => _musicalContent;
  String? get animated => _animated;
  String? get educationalContent => _educationalContent;
  String? get featured => _featured;
  String? get status => _status;
  dynamic get trailerUrl => _trailerUrl;
  String? get ageGroup => _ageGroup;
  String? get tags => _tags;
  String? get releaseDate => _releaseDate;
  String? get categoryId => _categoryId;
  String? get views => _views;
  String? get rating => _rating;
  dynamic get youtubeVideoId => _youtubeVideoId;
  String? get uploadedAt => _uploadedAt;
  bool? get isLoading => _isLoading;


  set isLoading(bool? value) {
    _isLoading = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = _username;
    map['title'] = _title;
    map['description'] = _description;
    map['slugs'] = _slugs;
    map['duration'] = _duration;
    map['file_path'] = _filePath;
    map['video_file_size'] = _videoFileSize;
    map['cover_photo_path'] = _coverPhotoPath;
    map['thumbnail_url'] = _thumbnailUrl;
    map['biblical_themes'] = _biblicalThemes;
    map['musical_content'] = _musicalContent;
    map['animated'] = _animated;
    map['educational_content'] = _educationalContent;
    map['featured'] = _featured;
    map['status'] = _status;
    map['trailer_url'] = _trailerUrl;
    map['age_group'] = _ageGroup;
    map['tags'] = _tags;
    map['release_date'] = _releaseDate;
    map['category_id'] = _categoryId;
    map['views'] = _views;
    map['rating'] = _rating;
    map['youtube_video_id'] = _youtubeVideoId;
    map['uploaded_at'] = _uploadedAt;
    return map;
  }

}