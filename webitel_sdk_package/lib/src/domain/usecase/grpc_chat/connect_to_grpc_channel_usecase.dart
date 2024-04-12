import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ConnectToGrpcChannelUseCase {
  Future<void> call();
}

class ConnectToGrpcChannelImplUseCase implements ConnectToGrpcChannelUseCase {
  final GrpcChatService _grpcChatService;

  ConnectToGrpcChannelImplUseCase(this._grpcChatService);

  @override
  Future<void> call() => _grpcChatService.connectToGrpcChannel();
}
