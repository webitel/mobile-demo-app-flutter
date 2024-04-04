library webitel_sdk_package;

import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/connect_to_grpc_channel_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/ping_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/initialize/init_grpc_usecase.dart';

final class WebitelSdkPackage {
  late ConnectToGrpcChannelUseCase _connectToGrpcChannelUseCase;
  late InitGrpcUseCase _initUseCase;
  late PingUseCase _pingUseCase;

  WebitelSdkPackage();

  Future<void> registerDependencies() async {
    await registerDi();
  }

  Future<void> initGrpc() async {
    _initUseCase =
        locator.get<InitGrpcUseCase>(instanceName: "InitGrpcUseCase");
    return await _initUseCase();
  }

  Future<String> connectToGrpcChannel({
    required String deviceId,
    required String clientToken,
    required String accessToken,
  }) async {
    _connectToGrpcChannelUseCase = locator.get<ConnectToGrpcChannelUseCase>(
        instanceName: "ConnectToGrpcChannelUseCase");
    return await _connectToGrpcChannelUseCase(
      accessToken: accessToken,
      deviceId: deviceId,
      clientToken: clientToken,
    );
  }

  Future<String> pingServer({required List<int> echo}) async {
    _pingUseCase = locator.get<PingUseCase>(instanceName: "PingUseCase");
    return await _pingUseCase(echo: echo);
  }
}
