import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/services/initialize/initialize_service.dart';
import 'package:webitel_sdk_package/src/generated/portal/account.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/auth.pb.dart';

class InitializeServiceImpl implements InitializeService {
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final GrpcGateway _grpcGateway;

  InitializeServiceImpl(this._grpcGateway, this._sharedPreferencesGateway);

  @override
  Future<RequestStatusResponse> initGrpcClient({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  }) async {
    final uuid = Uuid();
    await _sharedPreferencesGateway.init();
    deviceId == null
        ? await _sharedPreferencesGateway.saveDeviceId(uuid.v4())
        : await _sharedPreferencesGateway.saveDeviceId(deviceId);
    final savedDeviceId = await _sharedPreferencesGateway.readDeviceId();
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

    try {
      final response = await _grpcGateway.stub.token(request);
      await _sharedPreferencesGateway.saveUserId(response.chat.user.id);
      _grpcGateway.setAccessToken(response.accessToken);
      return RequestStatusResponse(status: RequestStatus.success);
    } catch (error) {
      return RequestStatusResponse(
          status: RequestStatus.error, message: error.toString());
    }
  }
}
