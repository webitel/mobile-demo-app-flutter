import 'package:webitel_portal_sdk/src/domain/entities/media_file/media_file_response.dart';
import 'package:webitel_portal_sdk/src/domain/entities/peer.dart';

enum MessageType { user, operator, error }

class DialogMessageResponseEntity {
  final String id;
  final MediaFileResponseEntity? file;
  final String dialogMessageContent;
  final PeerInfo peer;
  final MessageType? type;
  final String requestId;
  final String? chatId;
  final String? messageId;

  DialogMessageResponseEntity({
    required this.id,
    required this.requestId,
    required this.dialogMessageContent,
    required this.peer,
    this.type,
    this.file,
    this.chatId,
    this.messageId,
  });
}
