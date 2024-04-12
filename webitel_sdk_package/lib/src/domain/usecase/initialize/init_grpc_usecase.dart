import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';

abstract interface class InitGrpcUseCase {
  Future<void> call({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  });
}

class GrpcInitImplUseCase implements InitGrpcUseCase {
  final InitializeService _initializeService;

  GrpcInitImplUseCase(this._initializeService);

  @override
  Future<void> call({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  }) =>
      _initializeService.initGrpcClient(
        baseUrl: baseUrl,
        clientToken: clientToken,
        deviceId: deviceId,
      );
}
