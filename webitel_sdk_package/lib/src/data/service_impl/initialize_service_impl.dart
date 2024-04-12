import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';

class InitializeServiceImpl implements InitializeService {
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final GrpcGateway _grpcGateway;

  InitializeServiceImpl(this._grpcGateway, this._sharedPreferencesGateway);

  @override
  Future<void> initGrpcClient({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  }) async {
    await _grpcGateway.init(
        baseUrl: baseUrl, clientToken: clientToken, deviceId: deviceId);
    await _sharedPreferencesGateway.init();
  }
}
