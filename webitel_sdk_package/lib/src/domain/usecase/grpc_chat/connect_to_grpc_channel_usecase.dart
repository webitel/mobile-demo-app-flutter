import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ConnectToGrpcChannelUseCase {
  Future<String> call({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  });
}

class ConnectToGrpcChannelImplUseCase implements ConnectToGrpcChannelUseCase {
  final GrpcChatService _grpcChatService;

  ConnectToGrpcChannelImplUseCase(this._grpcChatService);

  @override
  Future<String> call({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) =>
      _grpcChatService.connectToGrpcChannel(
        deviceId: deviceId,
        clientToken: clientToken,
        accessToken: accessToken,
      );
}
