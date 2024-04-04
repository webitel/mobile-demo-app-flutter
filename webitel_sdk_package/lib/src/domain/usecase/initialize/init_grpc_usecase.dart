import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';

abstract class InitGrpcUseCase {
  Future<void> call();
}

class GrpcInitImplUseCase implements InitGrpcUseCase {
  final InitializeService _initializeService;

  GrpcInitImplUseCase(this._initializeService);

  @override
  Future<void> call() => _initializeService.initGrpcClient();
}
