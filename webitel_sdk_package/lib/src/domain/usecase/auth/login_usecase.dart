import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';

abstract interface class LoginUseCase {
  Future<RequestStatusResponse> call({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
    required String appToken,
    String? deviceId,
  });
}

class LoginImplUseCase implements LoginUseCase {
  final AuthService _authService;

  LoginImplUseCase(this._authService);

  @override
  Future<RequestStatusResponse> call({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
    required String appToken,
    String? deviceId,
  }) =>
      _authService.login(
        appToken: appToken,
        baseUrl: baseUrl,
        clientToken: clientToken,
        deviceId: deviceId,
        appName: appName,
        appVersion: appVersion,
        osName: osName,
        osVersion: osVersion,
        deviceModel: deviceModel,
      );
}
