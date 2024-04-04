import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class SendMessageUseCase {
  Future<void> call();
}

class SendMessageUseCaseImplUseCase implements SendMessageUseCase {
  final GrpcChatService _grpcChatService;

  SendMessageUseCaseImplUseCase(this._grpcChatService);

  @override
  Future<void> call() => _grpcChatService.sendMessage();
}
