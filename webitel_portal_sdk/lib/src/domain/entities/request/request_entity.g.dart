// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestEntity _$RequestEntityFromJson(Map<String, dynamic> json) =>
    RequestEntity(
      chatId: json['chatId'] as String,
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      path: json['path'] as String,
    );

Map<String, dynamic> _$RequestEntityToJson(RequestEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'path': instance.path,
    };
