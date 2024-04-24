import 'package:json_annotation/json_annotation.dart';

part 'request_entity.g.dart';

@JsonSerializable()
class RequestEntity {
  final String id;
  final String chatId;
  final String text;
  final DateTime timestamp;
  final String path;

  RequestEntity({
    required this.chatId,
    required this.id,
    required this.text,
    required this.timestamp,
    required this.path,
  });

  factory RequestEntity.fromJson(Map<String, dynamic> json) =>
      _$RequestEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RequestEntityToJson(this);
}
