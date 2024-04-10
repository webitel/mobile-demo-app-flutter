import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/connect_to_grpc_channel_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/initialize/init_grpc_usecase.dart';

class Initializer {
  late InitGrpcUseCase _initGrpcUseCase;
  late ConnectToGrpcChannelUseCase _connectToGrpcChannelUseCase;

  Initializer() {
    _connectToGrpcChannelUseCase = locator.get<ConnectToGrpcChannelUseCase>(
        instanceName: "ConnectToGrpcChannelUseCase");
    _initGrpcUseCase =
        locator.get<InitGrpcUseCase>(instanceName: "InitGrpcUseCase");
  }

  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    await _initGrpcUseCase();
    return await _connectToGrpcChannelUseCase(
      accessToken: accessToken,
      deviceId: deviceId,
      clientToken: clientToken,
    );
  }
}
