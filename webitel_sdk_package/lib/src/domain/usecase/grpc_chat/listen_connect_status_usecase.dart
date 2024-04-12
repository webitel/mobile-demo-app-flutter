import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ListenConnectStatusUseCase {
  Future<ConnectStatus> call();
}

class ListenConnectStatusImplUseCase implements ListenConnectStatusUseCase {
  final GrpcChatService _grpcChatService;

  ListenConnectStatusImplUseCase(this._grpcChatService);

  @override
  Future<ConnectStatus> call() => _grpcChatService.listenConnectStatus();
}
