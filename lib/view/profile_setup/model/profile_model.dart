enum ProfileType { kids, adult }
enum Gender { male, female }

class ProfileModel {
  late final ProfileType type;
  late final String id;
  late final String name;
  late final DateTime? dateOfBirth;
  late final Gender? gender;
  late final String? screenTime;

  ProfileModel({
    required this.type,
    this.name = '',
    this.id = '',
    this.dateOfBirth,
    this.gender,
    this.screenTime,
  });

  ProfileModel copyWith({
    ProfileType? type,
    String? id,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    String? screenTime,
  }) {
    return ProfileModel(
      type: type ?? this.type,
      name: name ?? this.name,
      id: id ?? this.id,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      screenTime: screenTime ?? this.screenTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender?.toString().split('.').last,
      'screenTime': screenTime,
    };
  }
}


class ProfileResponse {
  final int responseCode;
  final String responseMessage;
  final List<UserProfile> data;

  ProfileResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      responseCode: json['response_code'] ?? 0,
      responseMessage: json['response_message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String dob;
  final String ageGroup;
  final String avatar;
  final String createdAt;
  final String currentAge;

  UserProfile({
    required this.id,
    required this.name,
    required this.dob,
    required this.ageGroup,
    required this.avatar,
    required this.createdAt,
    required this.currentAge,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dob: json['dob'] ?? '',
      ageGroup: json['age_group'] ?? '',
      avatar: json['avatar'] ?? 'default.png',
      createdAt: json['created_at'] ?? '',
      currentAge: json['current_age'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'age_group': ageGroup,
      'avatar': avatar,
      'created_at': createdAt,
      'current_age': currentAge,
    };
  }

  ProfileType get profileType {
    switch (ageGroup.toLowerCase()) {
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

  bool get isKidsProfile => ageGroup.toLowerCase() != 'adult';
}