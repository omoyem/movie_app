import 'dart:convert';
GetFavouritesRequest getFavouritesRequestFromJson(String str) => GetFavouritesRequest.fromJson(json.decode(str));
String getFavouritesRequestToJson(GetFavouritesRequest data) => json.encode(data.toJson());
class GetFavouritesRequest {
  GetFavouritesRequest({
      String? userId, 
      String? profileId,}){
    _userId = userId;
    _profileId = profileId;
}

  GetFavouritesRequest.fromJson(dynamic json) {
    _userId = json['user_id'];
    _profileId = json['profile_id'];
  }
  String? _userId;
  String? _profileId;
GetFavouritesRequest copyWith({  String? userId,
  String? profileId,
}) => GetFavouritesRequest(  userId: userId ?? _userId,
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