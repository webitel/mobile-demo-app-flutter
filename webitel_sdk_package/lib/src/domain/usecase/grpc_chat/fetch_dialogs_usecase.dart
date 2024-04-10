import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';

abstract interface class FetchDialogsUseCase {
  Future<List<DialogMessageEntity>> call();
}

class FetchDialogsImplUseCase implements FetchDialogsUseCase {
  final GrpcChatService _grpcChatService;

  FetchDialogsImplUseCase(this._grpcChatService);

  @override
  Future<List<DialogMessageEntity>> call() => _grpcChatService.fetchDialogs();
}
