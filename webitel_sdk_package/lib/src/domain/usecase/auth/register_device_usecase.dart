import 'package:injectable/injectable.dart';
import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/services/auth_service.dart';

abstract interface class RegisterDeviceUseCase {
  Future<RequestStatusResponse> call();
}

@LazySingleton(as: RegisterDeviceUseCase)
class RegisterDeviceImplUseCase implements RegisterDeviceUseCase {
  final AuthService _authService;

  RegisterDeviceImplUseCase(this._authService);

  @override
  Future<RequestStatusResponse> call() => _authService.registerDevice();
}
