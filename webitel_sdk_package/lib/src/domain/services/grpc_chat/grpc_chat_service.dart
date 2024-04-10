import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';

abstract interface class GrpcChatService {
  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  });

  Future<List<DialogMessageEntity>> fetchDialogs();

  Future<List<DialogMessageEntity>> fetchUpdates();

  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message});
}
