import 'package:injectable/injectable.dart';
import 'package:webitel_portal_sdk/src/domain/entities/dialog_message.dart';
import 'package:webitel_portal_sdk/src/domain/services/grpc_chat_service.dart';

abstract interface class FetchMessagesUseCase {
  Future<List<DialogMessageEntity>> call({int? limit, String? offset});
}

@LazySingleton(as: FetchMessagesUseCase)
class FetchMessagesImplUseCase implements FetchMessagesUseCase {
  final ChatService _chatService;

  FetchMessagesImplUseCase(this._chatService);

  @override
  Future<List<DialogMessageEntity>> call({int? limit, String? offset}) =>
      _chatService.fetchMessages(limit: limit, offset: offset);
}