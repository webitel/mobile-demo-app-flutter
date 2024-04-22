import 'package:injectable/injectable.dart';
import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/services/auth_service.dart';

abstract interface class LogoutUseCase {
  Future<RequestStatusResponse> call();
}

@LazySingleton(as: LogoutUseCase)
class LogoutImplUseCase implements LogoutUseCase {
  final AuthService _authService;

  LogoutImplUseCase(this._authService);

  @override
  Future<RequestStatusResponse> call() => _authService.logout();
}
