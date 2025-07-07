import 'dart:convert';
MovieRequest movieRequestFromJson(String str) => MovieRequest.fromJson(json.decode(str));
String movieRequestToJson(MovieRequest data) => json.encode(data.toJson());
class MovieRequest {
  MovieRequest({
      String? userId, 
      String? profileId,}){
    _userId = userId;
    _profileId = profileId;
}

  MovieRequest.fromJson(dynamic json) {
    _userId = json['user_id'];
    _profileId = json['profile_id'];
  }
  String? _userId;
  String? _profileId;
MovieRequest copyWith({  String? userId,
  String? profileId,
}) => MovieRequest(  userId: userId ?? _userId,
  profileId: profileId ?? _profileId,
);
  String? get userId => _userId;
  String? get profileId => _profileId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = _userId;
    map['profile_id'] = _profileId;
    return map;
  }

}