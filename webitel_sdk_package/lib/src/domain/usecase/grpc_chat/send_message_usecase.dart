import 'package:webitel_sdk_package/src/domain/entities/message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class SendMessageUseCase {
  Future<MessageEntity> call({required MessageEntity message});
}

class SendMessageUseCaseImplUseCase implements SendMessageUseCase {
  final GrpcChatService _grpcChatService;

  SendMessageUseCaseImplUseCase(this._grpcChatService);

  @override
  Future<MessageEntity> call({required MessageEntity message}) =>
      _grpcChatService.sendMessage(message: message);
}
