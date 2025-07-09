import 'dart:convert';
ResetPasswordRequest resetPasswordRequestFromJson(String str) => ResetPasswordRequest.fromJson(json.decode(str));
String resetPasswordRequestToJson(ResetPasswordRequest data) => json.encode(data.toJson());
class ResetPasswordRequest {
  ResetPasswordRequest({
      String? username, 
      String? password,}){
    _username = username;
    _password = password;
}

  ResetPasswordRequest.fromJson(dynamic json) {
    _username = json['username'];
    _password = json['password'];
  }
  String? _username;
  String? _password;
ResetPasswordRequest copyWith({  String? username,
  String? password,
}) => ResetPasswordRequest(  username: username ?? _username,
  password: password ?? _password,
);
  String? get username => _username;
  String? get password => _password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = _username;
    map['password'] = _password;
    return map;
  }

}