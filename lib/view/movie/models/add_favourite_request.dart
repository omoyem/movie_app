import 'dart:convert';
AddFavouriteRequest addFavouriteRequestFromJson(String str) => AddFavouriteRequest.fromJson(json.decode(str));
String addFavouriteRequestToJson(AddFavouriteRequest data) => json.encode(data.toJson());
class AddFavouriteRequest {
  AddFavouriteRequest({
      String? userId, 
      String? profileId, 
      String? movieId,}){
    _userId = userId;
    _profileId = profileId;
    _movieId = movieId;
}

  AddFavouriteRequest.fromJson(dynamic json) {
    _userId = json['user_id'];
    _profileId = json['profile_id'];
    _movieId = json['movie_id'];
  }
  String? _userId;
  String? _profileId;
  String? _movieId;
AddFavouriteRequest copyWith({  String? userId,
  String? profileId,
  String? movieId,
}) => AddFavouriteRequest(  userId: userId ?? _userId,
  profileId: profileId ?? _profileId,
  movieId: movieId ?? _movieId,
);
  String? get userId => _userId;
  String? get profileId => _profileId;
  String? get movieId => _movieId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = _userId;
    map['profile_id'] = _profileId;
    map['movie_id'] = _movieId;
    return map;
  }

}