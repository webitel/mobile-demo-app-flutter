import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';

abstract interface class LoginUseCase {
  Future<String> call();
}

class LoginUseCaseImplUseCase implements LoginUseCase {
  final AuthService _authService;

  LoginUseCaseImplUseCase(this._authService);

  @override
  Future<String> call() => _authService.login();
}
