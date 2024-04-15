import 'package:uuid/uuid.dart';
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
    final uuid = Uuid();
    await _sharedPreferencesGateway.init();
    deviceId ??
        await _sharedPreferencesGateway.saveToDisk('deviceId', uuid.v4());
    final savedDeviceId =
        await _sharedPreferencesGateway.getFromDisk('deviceId');
    if (savedDeviceId != null) {
      await _grpcGateway.init(
        baseUrl: baseUrl,
        clientToken: clientToken,
        deviceId: deviceId ?? savedDeviceId,
      );
    }
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

    final response = await _grpcGateway.stub.token(request);
    await _sharedPreferencesGateway.saveToDisk('userId', response.user.id);
    _grpcGateway.setAccessToken(response.accessToken);
  }
}
