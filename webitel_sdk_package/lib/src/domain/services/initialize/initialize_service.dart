import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';

abstract interface class InitializeService {
  Future<RequestStatusResponse> initGrpcClient({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
    String? deviceId,
  });
}
