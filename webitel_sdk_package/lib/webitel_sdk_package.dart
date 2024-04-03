library webitel_sdk_package;

import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/services/auth_service.dart';

class WebitelSdkPackage {
  late AuthService _authService;

  WebitelSdkPackage() {
    registerServices();
    _authService = locator.get<AuthService>(instanceName: "AuthServiceImpl");
  }

  Future<void> initGrpc() async {
    return await _authService.initGrpc();
  }

  Future<void> ping() async {
    return await _authService.ping();
  }
}
