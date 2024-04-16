import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_dialogs_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_updates_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/send_message_usecase.dart';

class DialogMessageHandler {
  late SendDialogMessageUseCase _sendDialogMessageUseCase;
  late ListenToMessagesUsecase _listenToMessagesUsecase;
  late FetchDialogsUseCase _fetchDialogsUseCase;
  late FetchUpdatesUseCase _fetchUpdatesUseCase;

  DialogMessageHandler() {
    _fetchDialogsUseCase =
        locator.get<FetchDialogsUseCase>(instanceName: "FetchDialogsUseCase");
    _fetchUpdatesUseCase =
        locator.get<FetchUpdatesUseCase>(instanceName: "FetchUpdatesUseCase");
    _sendDialogMessageUseCase = locator.get<SendDialogMessageUseCase>(
        instanceName: "SendDialogMessageUseCase");
    _listenToMessagesUsecase = locator.get<ListenToMessagesUsecase>(
        instanceName: "ListenToOperatorMessagesUsecase");
  }

  Future<Stream<DialogMessageEntity>> listenToMessages() async {
    return await _listenToMessagesUsecase();
  }

  Future<void> sendDialogMessage({
    required String dialogMessageContent,
    required String peerType,
    required String peerName,
    required String peerId,
    required String requestId,
  }) async {
    await _sendDialogMessageUseCase(
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

  Future<List<DialogMessageEntity>> fetchDialogs() async {
    return await _fetchDialogsUseCase();
  }

  Future<List<DialogMessageEntity>> fetchUpdates() async {
    return await _fetchUpdatesUseCase();
  }
}
