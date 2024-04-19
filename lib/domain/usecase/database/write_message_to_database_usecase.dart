import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/service/data_base_service.dart';

abstract interface class WriteMessageToDatabaseUseCase {
  Future<void> call({required DialogMessageEntity message});
}

class WriteMessageToDatabaseImplUseCase
    implements WriteMessageToDatabaseUseCase {
  final DatabaseService _databaseService;

  WriteMessageToDatabaseImplUseCase(this._databaseService);

  @override
  Future<void> call({required DialogMessageEntity message}) =>
      _databaseService.writeMessageToDatabase(message: message);
}
