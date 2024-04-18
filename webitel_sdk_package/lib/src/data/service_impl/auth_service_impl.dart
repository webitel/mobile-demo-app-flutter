import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/backbone/builder/token_request_builder.dart';
import 'package:webitel_sdk_package/src/backbone/builder/user_agent_builder.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/request_status_response.dart';
import 'package:webitel_sdk_package/src/domain/services/auth/auth_service.dart';
import 'package:webitel_sdk_package/src/generated/portal/account.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/customer.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/push.pb.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final GrpcGateway _grpcGateway;

  AuthServiceImpl(this._grpcGateway, this._sharedPreferencesGateway);

  @override
  Future<RequestStatusResponse> login({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
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
        userAgentBuilder: UserAgentBuilder(
          appName: appName,
          appVersion: appVersion,
          osName: osName,
          osVersion: osVersion,
          deviceModel: deviceModel,
        ),
      );
    }
    final request = TokenRequestBuilder()
        .setGrantType('identity')
        .setResponseType(['user', 'token', 'chat'])
        .setAppToken(
            '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw')
        .setIdentity(Identity(
          name: 'Volodia',
          sub: 'Test',
          iss: 'https://dev.webitel.com/portal',
        ))
        .build();

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

  @override
  Future<void> registerDevice() async {
    await _grpcGateway.stub
        .registerDevice(RegisterDeviceRequest(push: DevicePush()));
  }

  @override
  Future<void> logout() async {
    await _grpcGateway.stub.logout(LogoutRequest());
  }
}
