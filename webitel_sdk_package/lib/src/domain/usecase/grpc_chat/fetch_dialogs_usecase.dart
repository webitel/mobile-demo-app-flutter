import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchDialogsUseCase {
  Future<void> call();
}

class FetchDialogsImplUseCase implements FetchDialogsUseCase {
  final GrpcChatService _grpcChatService;

  FetchDialogsImplUseCase(this._grpcChatService);

  @override
  Future<void> call() => _grpcChatService.fetchDialogs();
}
