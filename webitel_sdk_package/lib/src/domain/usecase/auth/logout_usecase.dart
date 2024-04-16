import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';

abstract interface class LogoutUseCase {
  Future<void> call();
}

class LogoutImplUseCase implements LogoutUseCase {
  final AuthService _authService;

  LogoutImplUseCase(this._authService);

  @override
  Future<void> call() => _authService.logout();
}
