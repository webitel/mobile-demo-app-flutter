import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/initialize/init_grpc_usecase.dart';

class Initializer {
  late InitGrpcUseCase _initGrpcUseCase;

  Initializer() {
    _initGrpcUseCase =
        locator.get<InitGrpcUseCase>(instanceName: "InitGrpcUseCase");
  }

  Future<void> initGrpc() async {
    return await _initGrpcUseCase();
  }
}
