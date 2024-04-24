// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
      accessToken: json['accessToken'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      clientToken: json['clientToken'] as String,
      deviceId: json['deviceId'] as String,
      appName: json['appName'] as String,
      appVersion: json['appVersion'] as String,
      packageName: json['packageName'] as String,
      packageVersion: json['packageVersion'] as String,
      userAgent: json['userAgent'] as String,
    );

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'baseUrl': instance.baseUrl,
      'clientToken': instance.clientToken,
      'deviceId': instance.deviceId,
      'accessToken': instance.accessToken,
      'appName': instance.appName,
      'appVersion': instance.appVersion,
      'packageName': instance.packageName,
      'packageVersion': instance.packageVersion,
      'userAgent': instance.userAgent,
    };
