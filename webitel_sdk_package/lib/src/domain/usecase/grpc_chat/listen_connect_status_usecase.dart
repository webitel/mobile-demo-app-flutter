import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ListenConnectStatusUseCase {
  Future<Stream<ConnectStreamStatus>> call();
}

class ListenConnectStatusImplUseCase implements ListenConnectStatusUseCase {
  final GrpcChatService _grpcChatService;

  ListenConnectStatusImplUseCase(this._grpcChatService);

  @override
  Future<Stream<ConnectStreamStatus>> call() =>
      _grpcChatService.listenConnectStatus();
}
