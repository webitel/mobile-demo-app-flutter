library webitel_sdk_package;

import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/init_grpc_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/ping_usecase.dart';

class WebitelSdkPackage {
  late InitUseCase _initUseCase;
  late PingUseCase _pingUseCase;

  WebitelSdkPackage();

  Future<void> initGrpc() async {
    _initUseCase = locator.get<InitUseCase>(instanceName: "InitUseCase");
    return await _initUseCase();
  }

  Future<String> ping() async {
    _pingUseCase = locator.get<PingUseCase>(instanceName: "PingUseCase");
    return await _pingUseCase();
  }

  Future<void> registerDependencies() async {
    await registerServices();
  }
}
