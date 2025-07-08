import 'dart:convert';
ForgotPasswordResponse forgotPasswordResponseFromJson(String str) => ForgotPasswordResponse.fromJson(json.decode(str));
String forgotPasswordResponseToJson(ForgotPasswordResponse data) => json.encode(data.toJson());
class ForgotPasswordResponse {
  ForgotPasswordResponse({
      num? responseCode, 
      String? responseMessage,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
}

  ForgotPasswordResponse.fromJson(dynamic json) {
    _responseCode = json['response_code'];
    _responseMessage = json['response_message'];
  }
  num? _responseCode;
  String? _responseMessage;
ForgotPasswordResponse copyWith({  num? responseCode,
  String? responseMessage,
}) => ForgotPasswordResponse(  responseCode: responseCode ?? _responseCode,
  responseMessage: responseMessage ?? _responseMessage,
);
  num? get responseCode => _responseCode;
  String? get responseMessage => _responseMessage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['response_code'] = _responseCode;
    map['response_message'] = _responseMessage;
    return map;
  }

}