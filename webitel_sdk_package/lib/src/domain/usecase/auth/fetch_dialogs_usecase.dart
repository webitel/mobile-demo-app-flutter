import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchDialogsUseCase {
  Future<void> call();
}

class FetchDialogsUseCaseImplUseCase implements FetchDialogsUseCase {
  final GrpcChatService _grpcChatService;

  FetchDialogsUseCaseImplUseCase(this._grpcChatService);

  @override
  Future<void> call() => _grpcChatService.fetchDialogs();
}
