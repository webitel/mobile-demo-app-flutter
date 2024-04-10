import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_dialogs_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/fetch_updates_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/listen_to_operator_messages_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/send_message_usecase.dart';

class DialogMessageHandler {
  late SendDialogMessageUseCase _sendDialogMessageUseCase;
  late ListenToOperatorMessagesUsecase _listenToOperatorMessagesUsecase;
  late FetchDialogsUseCase _fetchDialogsUseCase;
  late FetchUpdatesUseCase _fetchUpdatesUseCase;

  DialogMessageHandler() {
    _fetchDialogsUseCase =
        locator.get<FetchDialogsUseCase>(instanceName: "FetchDialogsUseCase");
    _fetchUpdatesUseCase =
        locator.get<FetchUpdatesUseCase>(instanceName: "FetchUpdatesUseCase");
    _sendDialogMessageUseCase = locator.get<SendDialogMessageUseCase>(
        instanceName: "SendDialogMessageUseCase");
    _listenToOperatorMessagesUsecase =
        locator.get<ListenToOperatorMessagesUsecase>(
            instanceName: "ListenToOperatorMessagesUsecase");
  }

  Future<Stream<DialogMessageEntity>> listenToOperatorMessages() async {
    return await _listenToOperatorMessagesUsecase();
  }

  Future<DialogMessageEntity> sendDialogMessage({
    required String dialogMessageContent,
    required String peerType,
    required String peerName,
    required String peerId,
  }) async {
    return await _sendDialogMessageUseCase(
      message: DialogMessageEntity(
        dialogMessageContent: dialogMessageContent,
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
