import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/logout_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/register_device_usecase.dart';

class AuthHandler {
  late RegisterDeviceUseCase _registerDeviceUseCase;
  late LogoutUseCase _logoutUseCase;

  AuthHandler() {
    _registerDeviceUseCase = locator.get<RegisterDeviceUseCase>(
        instanceName: "RegisterDeviceUseCase");
    _logoutUseCase = locator.get<LogoutUseCase>(instanceName: "LogoutUseCase");
  }

  Future<void> logout() async {
    await _logoutUseCase();
  }

  Future<void> registerDevice() async {
    await _registerDeviceUseCase();
  }
}
