import 'package:webitel_sdk/domain/entity/media_file.dart';

import 'msg_type.dart';

enum MessageStatus { loading, error, sent }

class DialogMessageEntity {
  final int id;
  final String? fileName;
  final String? fileId;
  final String? fileType;
  final String? path;
  final String dialogMessageContent;
  final MsgType? messageType;
  final MessageStatus? messageStatus;
  final String? chatId;
  final MediaFileEntity? file;
  final Keyboard? keyboard;

  DialogMessageEntity({
    this.keyboard,
    this.fileId,
    this.fileType,
    this.file,
    this.fileName,
    this.path,
    this.chatId,
    this.messageType,
    this.messageStatus,
    required this.id,
    required this.dialogMessageContent,
  });

  factory DialogMessageEntity.fromMap(Map<String, dynamic> map) {
    return DialogMessageEntity(
      chatId: map['chatId'],
      id: map['id'],
      fileId: map['fileId'],
      path: map['path'],
      fileName: map['fileName'],
      fileType: map['fileType'],
      messageType: map['messageType'] != null
          ? MsgType.values
              .firstWhere((type) => type.toString() == map['messageType'])
          : null,
      messageStatus: map['messageStatus'] != null
          ? MessageStatus.values
              .firstWhere((status) => status.toString() == map['messageStatus'])
          : null,
      dialogMessageContent: map['dialogMessageContent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'id': id,
      'fileId': fileId,
      'path': path,
      'fileType': fileType,
      'fileName': fileName,
      'messageType': messageType?.toString(),
      'messageStatus': messageStatus?.toString(),
      'dialogMessageContent': dialogMessageContent,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

class Keyboard {
  final List<List<Button>> buttons;

  Keyboard({
    required this.buttons,
  });
}

class Button {
  final String text;
  final String? code;
  final String? url;

  Button({
    required this.text,
    this.code,
    this.url,
  });
}
