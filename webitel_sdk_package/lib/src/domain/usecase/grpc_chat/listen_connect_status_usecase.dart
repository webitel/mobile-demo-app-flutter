import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ListenConnectStatusUseCase {
  Future<Stream<ConnectStatus>> call();
}

class ListenConnectStatusImplUseCase implements ListenConnectStatusUseCase {
  final GrpcChatService _grpcChatService;

  ListenConnectStatusImplUseCase(this._grpcChatService);

  @override
  Future<Stream<ConnectStatus>> call() =>
      _grpcChatService.listenConnectStatus();
}
