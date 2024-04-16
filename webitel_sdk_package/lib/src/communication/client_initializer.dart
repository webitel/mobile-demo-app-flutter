import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/initialize/init_grpc_usecase.dart';

class ClientInitializer {
  late InitGrpcUseCase _initGrpcUseCase;

  ClientInitializer() {
    _initGrpcUseCase = locator.get<InitGrpcUseCase>(
      instanceName: "InitGrpcUseCase",
    );
  }

  Future<void> initializeClient({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  }) async {
    await _initGrpcUseCase(
      baseUrl: baseUrl,
      clientToken: clientToken,
      deviceId: deviceId,
    );
  }
}
