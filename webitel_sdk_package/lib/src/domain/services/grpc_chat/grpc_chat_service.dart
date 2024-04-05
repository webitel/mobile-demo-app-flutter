import 'package:webitel_sdk_package/src/domain/entities/message.dart';

abstract interface class GrpcChatService {
  Future<List<int>> ping({required List<int> echo});

  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  });

  Future<void> fetchDialogs();

  Future<void> fetchUpdates();

  Future<MessageEntity> sendMessage({required MessageEntity message});
}
