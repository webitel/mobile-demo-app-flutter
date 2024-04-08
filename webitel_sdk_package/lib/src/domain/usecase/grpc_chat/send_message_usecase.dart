import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class SendDialogMessageUseCase {
  Future<DialogMessageEntity> call({required DialogMessageEntity message});
}

class SendDialogMessageImplUseCase implements SendDialogMessageUseCase {
  final GrpcChatService _grpcChatService;

  SendDialogMessageImplUseCase(this._grpcChatService);

  @override
  Future<DialogMessageEntity> call({required DialogMessageEntity message}) =>
      _grpcChatService.sendDialogMessage(message: message);
}
