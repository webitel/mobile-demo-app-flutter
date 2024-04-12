import 'package:webitel_sdk/domain/service/local_storage_service.dart';

abstract interface class FetchDeviceIdUseCase {
  Future<String> call();
}

class FetchDeviceIdUseCaseImplUseCase implements FetchDeviceIdUseCase {
  final LocalStorageService _localStorageService;

  FetchDeviceIdUseCaseImplUseCase(this._localStorageService);

  @override
  Future<String> call() => _localStorageService.fetchDeviceId();
}
