import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/logout_usecase.dart';

class AuthHandler {
  late LogoutUseCase _logoutUseCase;

  AuthHandler() {
    _logoutUseCase = locator.get<LogoutUseCase>(instanceName: "LogoutUseCase");
  }

  Future<void> logout() async {
    await _logoutUseCase();
  }
}
