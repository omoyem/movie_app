import 'dart:convert';
BaseResponse baseResponseFromJson(String str) => BaseResponse.fromJson(json.decode(str));
String baseResponseToJson(BaseResponse data) => json.encode(data.toJson());
class BaseResponse {
  BaseResponse({
      num? responseCode, 
      String? responseMessage,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
}

  BaseResponse.fromJson(dynamic json) {
    _responseCode = json['response_code'];
    _responseMessage = json['response_message'];
  }
  num? _responseCode;
  String? _responseMessage;
BaseResponse copyWith({  num? responseCode,
  String? responseMessage,
}) => BaseResponse(  responseCode: responseCode ?? _responseCode,
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