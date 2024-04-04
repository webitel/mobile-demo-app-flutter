import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class PingUseCase {
  Future<String> call({required List<int> echo});
}

class GrpcPingUseCase implements PingUseCase {
  final GrpcChatService _grpcChatService;

  GrpcPingUseCase(this._grpcChatService);

  @override
  Future<String> call({required List<int> echo}) =>
      _grpcChatService.ping(echo: echo);
}
