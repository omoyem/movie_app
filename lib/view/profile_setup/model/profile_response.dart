import 'dart:convert';

enum ProfileType { kids, adult }
enum Gender { male, female }


ProfileResponse profileResponseFromJson(String str) => ProfileResponse.fromJson(json.decode(str));
String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());
class ProfileResponse {
  ProfileResponse({
      num? responseCode, 
      String? responseMessage, 
      List<UserProfile>? data,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
    _data = data;
}

  ProfileResponse.fromJson(dynamic json) {
    _responseCode = json['response_code'];
    _responseMessage = json['response_message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(UserProfile.fromJson(v));
      });
    }
  }
  num? _responseCode;
  String? _responseMessage;
  List<UserProfile>? _data;
ProfileResponse copyWith({  num? responseCode,
  String? responseMessage,
  List<UserProfile>? data,
}) => ProfileResponse(  responseCode: responseCode ?? _responseCode,
  responseMessage: responseMessage ?? _responseMessage,
  data: data ?? _data,
);
  num? get responseCode => _responseCode;
  String? get responseMessage => _responseMessage;
  List<UserProfile>? get data => _data;

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

UserProfile dataFromJson(String str) => UserProfile.fromJson(json.decode(str));
String dataToJson(UserProfile data) => json.encode(data.toJson());
class UserProfile {
  UserProfile({
      String? id, 
      String? dob, 
      String? name, 
      String? gender, 
      String? screenTime, 
      String? ageGroup, 
      String? avatar, 
      String? createdAt, 
      String? currentAge,}){
    _id = id;
    _dob = dob;
    _name = name;
    _gender = gender;
    _screenTime = screenTime;
    _ageGroup = ageGroup;
    _avatar = avatar;
    _createdAt = createdAt;
    _currentAge = currentAge;
}

  UserProfile.fromJson(dynamic json) {
    _id = json['id'];
    _dob = json['dob'];
    _name = json['name'];
    _gender = json['gender'];
    _screenTime = json['screen_time'];
    _ageGroup = json['age_group'];
    _avatar = json['avatar'];
    _createdAt = json['created_at'];
    _currentAge = json['current_age'];
  }
  String? _id;
  String? _dob;
  String? _name;
  String? _gender;
  String? _screenTime;
  String? _ageGroup;
  String? _avatar;
  String? _createdAt;
  String? _currentAge;
  UserProfile copyWith({  String? id,
  String? dob,
  String? name,
  String? gender,
  String? screenTime,
  String? ageGroup,
  String? avatar,
  String? createdAt,
  String? currentAge,
}) => UserProfile(  id: id ?? _id,
  dob: dob ?? _dob,
  name: name ?? _name,
  gender: gender ?? _gender,
  screenTime: screenTime ?? _screenTime,
  ageGroup: ageGroup ?? _ageGroup,
  avatar: avatar ?? _avatar,
  createdAt: createdAt ?? _createdAt,
  currentAge: currentAge ?? _currentAge,
);
  String? get id => _id;
  String? get dob => _dob;
  String? get name => _name;
  String? get gender => _gender;
  String? get screenTime => _screenTime;
  String? get ageGroup => _ageGroup;
  String? get avatar => _avatar;
  String? get createdAt => _createdAt;
  String? get currentAge => _currentAge;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['dob'] = _dob;
    map['name'] = _name;
    map['gender'] = _gender;
    map['screen_time'] = _screenTime;
    map['age_group'] = _ageGroup;
    map['avatar'] = _avatar;
    map['created_at'] = _createdAt;
    map['current_age'] = _currentAge;
    return map;
  }

  ProfileType get profileType {
    switch (ageGroup?.toLowerCase()) {
      case 'adult':
        return ProfileType.adult;
      case 'child':
      case 'kid':
      case 'kids':
        return ProfileType.kids;
      default:
        return ProfileType.kids;
    }
  }

  bool get isKidsProfile => ageGroup?.toLowerCase() != 'adult';

}