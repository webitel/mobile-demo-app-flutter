import 'package:webitel_sdk/domain/service/data_base_service.dart';

abstract interface class WriteMessageToDatabaseUseCase {
  Future<void> call();
}

class WriteMessageToDatabaseImplUseCase
    implements WriteMessageToDatabaseUseCase {
  final DatabaseService _databaseService;

  WriteMessageToDatabaseImplUseCase(this._databaseService);

  @override
  Future<void> call() => _databaseService.writeMessages();
}
