import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/login_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/logout_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/register_device_usecase.dart';

class AuthHandler {
  late RegisterDeviceUseCase _registerDeviceUseCase;
  late LogoutUseCase _logoutUseCase;
  late LoginUseCase _loginUseCase;

  AuthHandler() {
    _registerDeviceUseCase = locator.get<RegisterDeviceUseCase>(
        instanceName: "RegisterDeviceUseCase");
    _logoutUseCase = locator.get<LogoutUseCase>(instanceName: "LogoutUseCase");
    _loginUseCase = locator.get<LoginUseCase>(
      instanceName: "LoginUseCase",
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
  }

  Future<void> registerDevice() async {
    await _registerDeviceUseCase();
  }

  Future<void> login({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
    String? deviceId,
  }) async {
    await _loginUseCase(
      baseUrl: baseUrl,
      clientToken: clientToken,
      deviceId: deviceId,
      appName: appName,
      appVersion: appVersion,
      osName: osName,
      osVersion: osVersion,
      deviceModel: deviceModel,
    );
  }
}
