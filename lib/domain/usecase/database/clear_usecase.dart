import 'package:webitel_sdk/domain/service/data_base_service.dart';

abstract interface class ClearDatabaseUseCase {
  Future<void> call();
}

class ClearDatabaseImplUseCase implements ClearDatabaseUseCase {
  final DatabaseService _databaseService;

  ClearDatabaseImplUseCase(this._databaseService);

  @override
  Future<void> call() => _databaseService.clear();
}
