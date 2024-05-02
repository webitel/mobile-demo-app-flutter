import 'dart:async';

import 'package:webitel_portal_sdk/src/domain/entities/dialog_message/dialog_message_request.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message/dialog_message_response.dart';
import 'package:webitel_portal_sdk/src/domain/entities/media_file/media_file_request.dart';
import 'package:webitel_portal_sdk/src/domain/entities/peer.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/fetch_message_updates.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/fetch_messages.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_portal_sdk/src/domain/usecase/chat/send_message_usecase.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class MessageHandler {
  late SendMessageUseCase _sendMessageUseCase;
  late FetchMessagesUseCase _fetchMessagesUseCase;
  late FetchUpdatesUseCase _fetchUpdatesUseCase;
  late ListenToMessagesUsecase _listenToMessagesUsecase;

  MessageHandler() {
    _fetchMessagesUseCase = getIt.get<FetchMessagesUseCase>();
    _fetchUpdatesUseCase = getIt.get<FetchUpdatesUseCase>();
    _sendMessageUseCase = getIt.get<SendMessageUseCase>();
    _listenToMessagesUsecase = getIt.get<ListenToMessagesUsecase>();
  }

  Future<DialogMessageResponseEntity> sendMessage({
    required String dialogMessageContent,
    required String peerType,
    required String peerName,
    required String peerId,
    required String requestId,
    String? mediaType,
    String? mediaName,
    Stream<List<int>>? mediaData,
  }) async {
    return await _sendMessageUseCase(
      message: DialogMessageRequestEntity(
        dialogMessageContent: dialogMessageContent,
        requestId: requestId,
        peer: PeerInfo(
          type: peerType,
          name: peerName,
          id: peerId,
        ),
        file: MediaFileRequestEntity(
          data: mediaData ?? Stream<List<int>>.empty(),
          name: mediaName ?? '',
          type: mediaType ?? '',
          requestId: requestId,
        ),
      ),
    );
  }

  Future<List<DialogMessageResponseEntity>> fetchMessages(
      {int? limit, String? offset}) async {
    return await _fetchMessagesUseCase(limit: limit, offset: offset);
  }

  Future<List<DialogMessageResponseEntity>> fetchUpdates(
      {int? limit, String? offset}) async {
    return await _fetchUpdatesUseCase(limit: limit, offset: offset);
  }

  Future<StreamController<DialogMessageResponseEntity>>
      listenToMessages() async {
    return await _listenToMessagesUsecase();
  }
}
