import 'dart:convert';
ForgotPasswordRequest forgotPasswordRequestFromJson(String str) => ForgotPasswordRequest.fromJson(json.decode(str));
String forgotPasswordRequestToJson(ForgotPasswordRequest data) => json.encode(data.toJson());
class ForgotPasswordRequest {
  ForgotPasswordRequest({
      String? username,}){
    _username = username;
}

  ForgotPasswordRequest.fromJson(dynamic json) {
    _username = json['username'];
  }
  String? _username;
ForgotPasswordRequest copyWith({  String? username,
}) => ForgotPasswordRequest(  username: username ?? _username,
);
  String? get username => _username;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = _username;
    return map;
  }

}