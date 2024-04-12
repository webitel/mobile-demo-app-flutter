import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';
import 'package:webitel_sdk_package/src/generated/portal/account.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/auth.pb.dart';

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
    await _sharedPreferencesGateway.init();
    await _grpcGateway.init(
        baseUrl: baseUrl, clientToken: clientToken, deviceId: deviceId);
    final request = TokenRequest(
      grantType: 'identity',
      responseType: ['user', 'token', 'chat'],
      appToken:
          '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
      identity: Identity(
        name: 'Volodia',
        sub: 'Test',
        iss: 'https://dev.webitel.com/portal',
      ),
    );

    final response = await _grpcGateway.customerClient.token(request);
    _grpcGateway.setAccessToken(response.accessToken);
  }
}
