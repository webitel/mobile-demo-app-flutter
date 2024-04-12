import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/login_usecase.dart';

class AuthHandler {
  late LoginUseCase _loginUseCase;

  AuthHandler() {
    _loginUseCase = locator.get<LoginUseCase>(instanceName: "LoginUseCase");
  }

  Future<String> login() async {
    return await _loginUseCase();
  }
}
