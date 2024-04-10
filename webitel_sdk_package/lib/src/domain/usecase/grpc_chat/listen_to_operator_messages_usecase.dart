import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ListenToOperatorMessagesUsecase {
  Future<Stream<DialogMessageEntity>> call();
}

class ListenToOperatorMessagesImplUseCase
    implements ListenToOperatorMessagesUsecase {
  final GrpcChatService _grpcChatService;

  ListenToOperatorMessagesImplUseCase(this._grpcChatService);

  @override
  Future<Stream<DialogMessageEntity>> call() =>
      _grpcChatService.listenToOperatorMessages();
}
