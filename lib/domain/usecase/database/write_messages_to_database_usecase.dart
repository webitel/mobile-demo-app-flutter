import 'package:webitel_sdk/domain/service/data_base_service.dart';

abstract interface class WriteMessagesToDatabaseUseCase {
  Future<void> call();
}

class WriteMessagesToDatabaseImplUseCase
    implements WriteMessagesToDatabaseUseCase {
  final DatabaseService _databaseService;

  WriteMessagesToDatabaseImplUseCase(this._databaseService);

  @override
  Future<void> call() => _databaseService.writeMessages();
}
