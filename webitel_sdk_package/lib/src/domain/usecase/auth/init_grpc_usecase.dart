import 'package:webitel_sdk_package/src/domain/services/auth_service.dart';

abstract class InitUseCase {
  Future<void> call();
}

class GrpcInitUseCase implements InitUseCase {
  final AuthService _authService;

  GrpcInitUseCase(this._authService);

  @override
  Future<void> call() => _authService.initGrpc();
}
