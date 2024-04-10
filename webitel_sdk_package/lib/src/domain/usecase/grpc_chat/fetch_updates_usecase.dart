import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchUpdatesUseCase {
  Future<List<DialogMessageEntity>> call();
}

class FetchUpdatesUseCaseImplUseCase implements FetchUpdatesUseCase {
  final GrpcChatService _grpcChatService;

  FetchUpdatesUseCaseImplUseCase(this._grpcChatService);

  @override
  Future<List<DialogMessageEntity>> call() => _grpcChatService.fetchUpdates();
}
