import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/service/data_base_service.dart';

abstract interface class FetchMessagesByChatIdUseCase {
  Future<List<DialogMessageEntity>> call();
}

class FetchMessagesByChatIdImplUseCase implements FetchMessagesByChatIdUseCase {
  final DatabaseService _databaseService;

  FetchMessagesByChatIdImplUseCase(this._databaseService);

  @override
  Future<List<DialogMessageEntity>> call() =>
      _databaseService.fetchMessagesByChatId(chatId: '');
}
