import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';

abstract interface class AuthService {
  Future<void> logout();

  Future<void> registerDevice();

  Future<RequestStatusResponse> login({
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
