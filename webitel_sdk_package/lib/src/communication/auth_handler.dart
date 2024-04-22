import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/login_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/logout_usecase.dart';
import 'package:webitel_sdk_package/src/domain/usecase/auth/register_device_usecase.dart';
import 'package:webitel_sdk_package/src/injection/injection.dart';

class AuthHandler {
  late RegisterDeviceUseCase _registerDeviceUseCase;
  late LogoutUseCase _logoutUseCase;
  late LoginUseCase _loginUseCase;

  AuthHandler() {
    _registerDeviceUseCase = getIt.get<RegisterDeviceUseCase>();
    _logoutUseCase = getIt.get<LogoutUseCase>();
    _loginUseCase = getIt.get<LoginUseCase>();
  }

  Future<RequestStatusResponse> logout() async {
    return await _logoutUseCase();
  }

  Future<RequestStatusResponse> registerDevice() async {
    return await _registerDeviceUseCase();
  }

  Future<RequestStatusResponse> login({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String userAgent,
    required String appToken,
    String? deviceId,
  }) async {
    return await _loginUseCase(
      appToken: appToken,
      baseUrl: baseUrl,
      clientToken: clientToken,
      deviceId: deviceId,
      appName: appName,
      appVersion: appVersion,
      userAgent: userAgent,
    );
  }
}
