import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/fetch_message_updates.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/fetch_messages.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/send_message_usecase.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class MessageHandler {
  late SendDialogMessageUseCase _sendDialogMessageUseCase;
  late FetchMessagesUseCase _fetchMessagesUseCase;
  late FetchMessageUpdatesUseCase _fetchMessageUpdatesUseCase;

  MessageHandler() {
    _fetchMessagesUseCase = getIt.get<FetchMessagesUseCase>();
    _fetchMessageUpdatesUseCase = getIt.get<FetchMessageUpdatesUseCase>();
    _sendDialogMessageUseCase = getIt.get<SendDialogMessageUseCase>();
  }

  Future<DialogMessageEntity> sendDialogMessage({
    required String dialogMessageContent,
    required String peerType,
    required String peerName,
    required String peerId,
    required String requestId,
  }) async {
    return await _sendDialogMessageUseCase(
      message: DialogMessageEntity(
        dialogMessageContent: dialogMessageContent,
        requestId: requestId,
        peer: PeerInfo(
          type: peerType,
          name: peerName,
          id: peerId,
        ),
      ),
    );
  }

  Future<List<DialogMessageEntity>> fetchMessages(
      {int? limit, String? offset}) async {
    return await _fetchMessagesUseCase(limit: limit, offset: offset);
  }

  Future<List<DialogMessageEntity>> fetchMessageUpdates(
      {int? limit, String? offset}) async {
    return await _fetchMessageUpdatesUseCase(limit: limit, offset: offset);
  }
}
