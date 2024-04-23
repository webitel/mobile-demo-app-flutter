import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

abstract interface class LoginUseCase {
  Future<ResponseEntity> call({
    required String appToken,
    required String baseUrl,
    required String clientToken,
  });
}

class LoginImplUseCase implements LoginUseCase {
  final AuthService _authService;

  LoginImplUseCase(this._authService);

  @override
  Future<ResponseEntity> call({
    required String appToken,
    required String baseUrl,
    required String clientToken,
  }) =>
      _authService.login(
        appToken: appToken,
        baseUrl: baseUrl,
        clientToken: clientToken,
      );
}
