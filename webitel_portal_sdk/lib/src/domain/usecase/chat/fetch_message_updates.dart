import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/services/grpc_chat_service.dart';

abstract interface class FetchMessageUpdatesUseCase {
  Future<List<DialogMessageEntity>> call({int? limit, String? offset});
}

@LazySingleton(as: FetchMessageUpdatesUseCase)
class FetchMessageUpdatesImplUseCase implements FetchMessageUpdatesUseCase {
  final ChatService _chatService;

  FetchMessageUpdatesImplUseCase(this._chatService);

  @override
  Future<List<DialogMessageEntity>> call({int? limit, String? offset}) =>
      _chatService.fetchMessageUpdates(limit: limit, offset: offset);
}
