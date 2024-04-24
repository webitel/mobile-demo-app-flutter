import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserEntity {
  final String id;
  final String name;
  final String baseUrl;
  final String clientToken;
  final String deviceId;
  final String accessToken;
  final String appName;
  final String appVersion;
  final String packageName;
  final String packageVersion;
  final String userAgent;

  UserEntity({
    required this.accessToken,
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.clientToken,
    required this.deviceId,
    required this.appName,
    required this.appVersion,
    required this.packageName,
    required this.packageVersion,
    required this.userAgent,
  });

  factory UserEntity.initial() {
    return UserEntity(
      accessToken: '',
      id: '',
      name: '',
      baseUrl: '',
      clientToken: '',
      deviceId: '',
      appName: '',
      appVersion: '',
      packageName: '',
      packageVersion: '',
      userAgent: '',
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);
}
