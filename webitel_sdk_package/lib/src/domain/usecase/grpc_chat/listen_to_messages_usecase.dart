import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class ListenToMessagesUsecase {
  Future<Stream<DialogMessageEntity>> call();
}

class ListenToMessagesImplUseCase implements ListenToMessagesUsecase {
  final GrpcChatService _grpcChatService;

  ListenToMessagesImplUseCase(this._grpcChatService);

  @override
  Future<Stream<DialogMessageEntity>> call() =>
      _grpcChatService.listenToMessages();
}