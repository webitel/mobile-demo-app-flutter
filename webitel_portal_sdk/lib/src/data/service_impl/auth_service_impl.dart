import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/builder/token_request_builder.dart';
import 'package:webitel_portal_sdk/src/builder/user_agent_builder.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/domain/entities/response_entity.dart';
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
  Future<ResponseEntity> login({
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
          name: 'Volodia Hunkalo',
          sub: 'Hunkalo acc2',
          iss: 'https://dev.webitel.com/portal',
        ))
        .build();

    try {
      final response = await _grpcGateway.stub.token(request);
      await _sharedPreferencesGateway.saveUserId(response.chat.user.id);
      _grpcGateway.setAccessToken(response.accessToken);
      return ResponseEntity(status: ResponseStatus.success);
    } catch (error) {
      return ResponseEntity(
          status: ResponseStatus.error, message: error.toString());
    }
  }

  @override
  Future<ResponseEntity> registerDevice() async {
    try {
      await _grpcGateway.stub
          .registerDevice(RegisterDeviceRequest(push: DevicePush()));
      return ResponseEntity(status: ResponseStatus.success);
    } catch (error) {
      return ResponseEntity(
          status: ResponseStatus.error, message: error.toString());
    }
  }

  @override
  Future<ResponseEntity> logout() async {
    try {
      await _grpcGateway.stub.logout(LogoutRequest());
      return ResponseEntity(status: ResponseStatus.success);
    } catch (error) {
      return ResponseEntity(
          status: ResponseStatus.error, message: error.toString());
    }
  }
}
