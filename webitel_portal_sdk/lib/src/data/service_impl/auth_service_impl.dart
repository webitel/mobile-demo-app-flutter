import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/builder/token_request_builder.dart';
import 'package:webitel_portal_sdk/src/builder/user_agent_builder.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/domain/entities/request_status_response.dart';
import 'package:webitel_portal_sdk/src/domain/services/auth_service.dart';
import 'package:webitel_portal_sdk/src/generated/portal/account.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/customer.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/push.pb.dart';

@LazySingleton(as: AuthService)
class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final GrpcGateway _grpcGateway;

  AuthServiceImpl(
    this._grpcGateway,
    this._sharedPreferencesGateway,
  );

  @override
  Future<RequestStatusResponse> login({
    required String baseUrl,
    required String clientToken,
    required String appName,
    required String appVersion,
    required String appToken,
    required String userAgent,
    String? deviceId,
  }) async {
    final uuid = Uuid();
    await _sharedPreferencesGateway.init();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
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
          packageName: packageInfo.appName,
          packageVersion: packageInfo.version,
          userAgent: userAgent,
        ),
      );
    }
    final request = TokenRequestBuilder()
        .setGrantType('identity')
        .setResponseType(['user', 'token', 'chat'])
        .setAppToken(appToken)
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
  Future<RequestStatusResponse> registerDevice() async {
    try {
      await _grpcGateway.stub
          .registerDevice(RegisterDeviceRequest(push: DevicePush()));
      return RequestStatusResponse(status: RequestStatus.success);
    } catch (error) {
      return RequestStatusResponse(
          status: RequestStatus.error, message: error.toString());
    }
  }

  @override
  Future<RequestStatusResponse> logout() async {
    try {
      await _grpcGateway.stub.logout(LogoutRequest());
      return RequestStatusResponse(status: RequestStatus.success);
    } catch (error) {
      return RequestStatusResponse(
          status: RequestStatus.error, message: error.toString());
    }
  }
}
