import 'package:webitel_portal_sdk/src/domain/entities/request_status_response.dart';

abstract interface class AuthService {
  Future<RequestStatusResponse> logout();

  Future<RequestStatusResponse> registerDevice();

  Future<RequestStatusResponse> login({
    required String baseUrl,
    required String userAgent,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String appToken,
    String? deviceId,
  });
}
