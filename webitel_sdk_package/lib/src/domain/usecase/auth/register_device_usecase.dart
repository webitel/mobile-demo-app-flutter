import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';

abstract interface class RegisterDeviceUseCase {
  Future<void> call();
}

class RegisterDeviceImplUseCase implements RegisterDeviceUseCase {
  final AuthService _authService;

  RegisterDeviceImplUseCase(this._authService);

  @override
  Future<void> call() => _authService.registerDevice();
}
