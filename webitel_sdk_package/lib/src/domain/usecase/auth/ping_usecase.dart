import 'package:webitel_sdk_package/src/domain/services/authorization/auth_service.dart';

abstract class PingUseCase {
  Future<String> call();
}

class GrpcPingUseCase implements PingUseCase {
  final AuthService _authService;

  GrpcPingUseCase(this._authService);

  @override
  Future<String> call() => _authService.ping();
}
