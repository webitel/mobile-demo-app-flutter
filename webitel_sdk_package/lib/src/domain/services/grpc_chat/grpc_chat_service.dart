import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

abstract interface class GrpcChatService {
  Future<String> connectToGrpcChannel();

  Future<List<DialogMessageEntity>> fetchDialogs();

  Future<List<DialogMessageEntity>> fetchUpdates();

  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message});

  Future<Stream<DialogMessageEntity>> listenToOperatorMessages(
      {required String id});
}
