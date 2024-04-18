import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchMessageUpdatesUseCase {
  Future<List<DialogMessageEntity>> call();
}

class FetchMessageUpdatesImplUseCase implements FetchMessageUpdatesUseCase {
  final GrpcChatService _grpcChatService;

  FetchMessageUpdatesImplUseCase(this._grpcChatService);

  @override
  Future<List<DialogMessageEntity>> call() =>
      _grpcChatService.fetchMessageUpdates();
}
