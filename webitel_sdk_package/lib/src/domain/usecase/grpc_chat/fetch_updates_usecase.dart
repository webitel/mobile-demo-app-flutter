import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchUpdatesUseCase {
  Future<void> call();
}

class FetchUpdatesUseCaseImplUseCase implements FetchUpdatesUseCase {
  final GrpcChatService _grpcChatService;

  FetchUpdatesUseCaseImplUseCase(this._grpcChatService);

  @override
  Future<void> call() => _grpcChatService.fetchUpdates();
}
