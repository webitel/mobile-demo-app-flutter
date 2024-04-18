import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchMessagesUseCase {
  Future<List<DialogMessageEntity>> call();
}

class FetchMessagesImplUseCase implements FetchMessagesUseCase {
  final GrpcChatService _grpcChatService;

  FetchMessagesImplUseCase(this._grpcChatService);

  @override
  Future<List<DialogMessageEntity>> call() => _grpcChatService.fetchMessages();
}
