import 'dart:convert';
LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));
String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());
class LoginResponse {
  LoginResponse({
      String? responseCode, 
      String? responseMessage, 
      Data? data,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
    _data = data;
}

  LoginResponse.fromJson(dynamic json) {
    _responseCode = json['response_code'];
    _responseMessage = json['response_message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _responseCode;
  String? _responseMessage;
  Data? _data;
LoginResponse copyWith({  String? responseCode,
  String? responseMessage,
  Data? data,
}) => LoginResponse(  responseCode: responseCode ?? _responseCode,
  responseMessage: responseMessage ?? _responseMessage,
  data: data ?? _data,
);
  String? get responseCode => _responseCode;
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
      String? firstname, 
      String? lastname, 
      String? username, 
      String? uniqueId, 
      String? role, 
      String? email, 
      List<Profiles>? profiles, 
      String? accessToken,}){
    _firstname = firstname;
    _lastname = lastname;
    _username = username;
    _uniqueId = uniqueId;
    _role = role;
    _email = email;
    _profiles = profiles;
    _accessToken = accessToken;
}

  Data.fromJson(dynamic json) {
    _firstname = json['firstname'];
    _lastname = json['lastname'];
    _username = json['username'];
    _uniqueId = json['unique_id'];
    _role = json['role'];
    _email = json['email'];
    if (json['profiles'] != null) {
      _profiles = [];
      json['profiles'].forEach((v) {
        _profiles?.add(Profiles.fromJson(v));
      });
    }
    _accessToken = json['access_token'];
  }
  String? _firstname;
  String? _lastname;
  String? _username;
  String? _uniqueId;
  String? _role;
  String? _email;
  List<Profiles>? _profiles;
  String? _accessToken;
Data copyWith({  String? firstname,
  String? lastname,
  String? username,
  String? uniqueId,
  String? role,
  String? email,
  List<Profiles>? profiles,
  String? accessToken,
}) => Data(  firstname: firstname ?? _firstname,
  lastname: lastname ?? _lastname,
  username: username ?? _username,
  uniqueId: uniqueId ?? _uniqueId,
  role: role ?? _role,
  email: email ?? _email,
  profiles: profiles ?? _profiles,
  accessToken: accessToken ?? _accessToken,
);
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get username => _username;
  String? get uniqueId => _uniqueId;
  String? get role => _role;
  String? get email => _email;
  List<Profiles>? get profiles => _profiles;
  String? get accessToken => _accessToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstname'] = _firstname;
    map['lastname'] = _lastname;
    map['username'] = _username;
    map['unique_id'] = _uniqueId;
    map['role'] = _role;
    map['email'] = _email;
    if (_profiles != null) {
      map['profiles'] = _profiles?.map((v) => v.toJson()).toList();
    }
    map['access_token'] = _accessToken;
    return map;
  }

}

Profiles profilesFromJson(String str) => Profiles.fromJson(json.decode(str));
String profilesToJson(Profiles data) => json.encode(data.toJson());
class Profiles {
  Profiles({
      String? id, 
      String? dob, 
      String? userId, 
      String? name, 
      String? gender, 
      String? avatar, 
      String? screenTime, 
      String? allowedRatings, 
      String? calculatedAge, 
      String? ageGroup, 
      String? createdAt, 
      dynamic updatedAt,}){
    _id = id;
    _dob = dob;
    _userId = userId;
    _name = name;
    _gender = gender;
    _avatar = avatar;
    _screenTime = screenTime;
    _allowedRatings = allowedRatings;
    _calculatedAge = calculatedAge;
    _ageGroup = ageGroup;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Profiles.fromJson(dynamic json) {
    _id = json['id'];
    _dob = json['dob'];
    _userId = json['user_id'];
    _name = json['name'];
    _gender = json['gender'];
    _avatar = json['avatar'];
    _screenTime = json['screen_time'];
    _allowedRatings = json['allowed_ratings'];
    _calculatedAge = json['calculated_age'];
    _ageGroup = json['age_group'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  String? _id;
  String? _dob;
  String? _userId;
  String? _name;
  String? _gender;
  String? _avatar;
  String? _screenTime;
  String? _allowedRatings;
  String? _calculatedAge;
  String? _ageGroup;
  String? _createdAt;
  dynamic _updatedAt;
Profiles copyWith({  String? id,
  String? dob,
  String? userId,
  String? name,
  String? gender,
  String? avatar,
  String? screenTime,
  String? allowedRatings,
  String? calculatedAge,
  String? ageGroup,
  String? createdAt,
  dynamic updatedAt,
}) => Profiles(  id: id ?? _id,
  dob: dob ?? _dob,
  userId: userId ?? _userId,
  name: name ?? _name,
  gender: gender ?? _gender,
  avatar: avatar ?? _avatar,
  screenTime: screenTime ?? _screenTime,
  allowedRatings: allowedRatings ?? _allowedRatings,
  calculatedAge: calculatedAge ?? _calculatedAge,
  ageGroup: ageGroup ?? _ageGroup,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  String? get id => _id;
  String? get dob => _dob;
  String? get userId => _userId;
  String? get name => _name;
  String? get gender => _gender;
  String? get avatar => _avatar;
  String? get screenTime => _screenTime;
  String? get allowedRatings => _allowedRatings;
  String? get calculatedAge => _calculatedAge;
  String? get ageGroup => _ageGroup;
  String? get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['dob'] = _dob;
    map['user_id'] = _userId;
    map['name'] = _name;
    map['gender'] = _gender;
    map['avatar'] = _avatar;
    map['screen_time'] = _screenTime;
    map['allowed_ratings'] = _allowedRatings;
    map['calculated_age'] = _calculatedAge;
    map['age_group'] = _ageGroup;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}