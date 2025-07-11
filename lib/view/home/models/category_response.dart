import 'dart:convert';
CategoryResponse categoryResponseFromJson(String str) => CategoryResponse.fromJson(json.decode(str));
String categoryResponseToJson(CategoryResponse data) => json.encode(data.toJson());
class CategoryResponse {
  CategoryResponse({
      num? responseCode, 
      String? responseMessage, 
      List<Data>? data,}){
    _responseCode = responseCode;
    _responseMessage = responseMessage;
    _data = data;
}

  CategoryResponse.fromJson(dynamic json) {
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
CategoryResponse copyWith({  num? responseCode,
  String? responseMessage,
  List<Data>? data,
}) => CategoryResponse(  responseCode: responseCode ?? _responseCode,
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
      String? name, 
      String? description,}){
    _id = id;
    _name = name;
    _description = description;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _description = json['description'];
  }
  String? _id;
  String? _name;
  String? _description;
Data copyWith({  String? id,
  String? name,
  String? description,
}) => Data(  id: id ?? _id,
  name: name ?? _name,
  description: description ?? _description,
);
  String? get id => _id;
  String? get name => _name;
  String? get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    return map;
  }

}