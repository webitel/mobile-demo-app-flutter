import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';

abstract interface class InitializeService {
  Future<RequestStatusResponse> initGrpcClient({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  });
}
