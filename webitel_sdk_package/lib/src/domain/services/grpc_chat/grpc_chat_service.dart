import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

abstract interface class GrpcChatService {
  Future<List<DialogMessageEntity>> fetchDialogs();

  Future<List<DialogMessageEntity>> fetchUpdates();

  Future<void> sendDialogMessage({required DialogMessageEntity message});

  Future<Stream<DialogMessageEntity>> listenToMessages();

  Future<Stream<ConnectStreamStatus>> listenConnectStatus();
}
