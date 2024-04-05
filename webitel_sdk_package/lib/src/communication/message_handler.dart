import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/entities/message.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/connect_to_grpc_channel_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/ping_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/send_message_usecase.dart';

class MessageHandler {
  late SendMessageUseCase _sendMessageUseCase;
  late ConnectToGrpcChannelUseCase _connectToGrpcChannelUseCase;
  late PingUseCase _pingUseCase;

  MessageHandler() {
    _sendMessageUseCase =
        locator.get<SendMessageUseCase>(instanceName: "SendMessageUseCase");
    _connectToGrpcChannelUseCase = locator.get<ConnectToGrpcChannelUseCase>(
        instanceName: "ConnectToGrpcChannelUseCase");
    _pingUseCase = locator.get<PingUseCase>(instanceName: "PingUseCase");
  }

  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    return await _connectToGrpcChannelUseCase(
      accessToken: accessToken,
      deviceId: deviceId,
      clientToken: clientToken,
    );
  }

  Future<List<int>> pingServer({required List<int> echo}) async {
    return await _pingUseCase(echo: echo);
  }

  Future<MessageEntity> sendMessage(
      {required String id, required int timestamp}) async {
    return await _sendMessageUseCase(
        message: MessageEntity(id: id, timestamp: timestamp));
  }
}
