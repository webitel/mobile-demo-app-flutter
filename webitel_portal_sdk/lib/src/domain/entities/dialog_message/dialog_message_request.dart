import 'package:webitel_portal_sdk/src/domain/entities/media_file/media_file_request.dart';
import 'package:webitel_portal_sdk/src/domain/entities/peer.dart';

class DialogMessageRequestEntity {
  final MediaFileRequestEntity? file;
  final String dialogMessageContent;
  final PeerInfo peer;
  final String requestId;
  final String? chatId;
  final String? messageId;

  DialogMessageRequestEntity({
    required this.requestId,
    required this.dialogMessageContent,
    required this.peer,
    this.file,
    this.chatId,
    this.messageId,
  });
}
