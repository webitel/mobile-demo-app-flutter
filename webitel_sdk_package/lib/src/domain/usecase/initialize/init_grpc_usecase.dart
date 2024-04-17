import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';

abstract interface class InitGrpcUseCase {
  Future<RequestStatusResponse> call({
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

class GrpcInitImplUseCase implements InitGrpcUseCase {
  final InitializeService _initializeService;

  GrpcInitImplUseCase(this._initializeService);

  @override
  Future<RequestStatusResponse> call({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
    String? deviceId,
  }) =>
      _initializeService.initGrpcClient(
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
