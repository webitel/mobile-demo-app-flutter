import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/backbone/constants.dart';
import 'package:webitel_portal_sdk/src/builder/token_request_builder.dart';
import 'package:webitel_portal_sdk/src/builder/user_agent_builder.dart';
import 'package:webitel_portal_sdk/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/database/database.dart';
import 'package:webitel_portal_sdk/src/domain/entities/response_entity.dart';
import 'package:webitel_portal_sdk/src/domain/entities/user/user.dart';
import 'package:webitel_portal_sdk/src/domain/services/auth_service.dart';
import 'package:webitel_portal_sdk/src/generated/portal/account.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/customer.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/push.pb.dart';

@LazySingleton(as: AuthService)
class AuthServiceImpl implements AuthService {
  final DatabaseProvider _databaseProvider;
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final GrpcGateway _grpcGateway;

  AuthServiceImpl(
    this._databaseProvider,
    this._grpcGateway,
    this._sharedPreferencesGateway,
  );

  @override
  Future<ResponseEntity> login({
    required String baseUrl,
    required String clientToken,
    required String appToken,
    required String userAgent,
  }) async {
    await _sharedPreferencesGateway.init();
    final deviceId = await getOrGenerateDeviceId();
    final userAgentString = buildUserAgent(userAgent: userAgent);

    await _grpcGateway.init(
      baseUrl: baseUrl,
      clientToken: clientToken,
      deviceId: deviceId,
      userAgent: userAgentString,
    );

    final request = TokenRequestBuilder()
        .setGrantType('identity')
        .setResponseType(['user', 'token', 'chat'])
        .setAppToken(appToken)
        .setIdentity(
          Identity(
            name: 'Volodia Hunkalo',
            sub: 'Hunkalo acc2',
            iss: Constants.iss,
          ),
        )
        .build();

    try {
      final response = await _grpcGateway.customerStub.token(request);
      await _sharedPreferencesGateway.saveUserId(response.chat.user.id);

      _databaseProvider.writeUser(
        UserEntity(
          accessToken: response.accessToken,
          id: response.chat.user.id,
          clientToken: clientToken,
          deviceId: deviceId,
        ),
      );

      _grpcGateway.setAccessToken(response.accessToken);
      return ResponseEntity(status: ResponseStatus.success);
    } on GrpcError catch (err) {
      final errorMessage = 'Failed to login: ${err.toString()}';
      return ResponseEntity(
          status: ResponseStatus.error, message: errorMessage);
    } catch (err) {
      final errorMessage = 'Failed to login: ${err.toString()}';
      return ResponseEntity(
          status: ResponseStatus.error, message: errorMessage);
    }
  }

  @override
  Future<ResponseEntity> registerDevice() async {
    try {
      await _grpcGateway.customerStub
          .registerDevice(RegisterDeviceRequest(push: DevicePush()));
      return ResponseEntity(status: ResponseStatus.success);
    } catch (err) {
      return ResponseEntity(
        status: ResponseStatus.error,
        message: 'Failed to register device: ${err.toString()}',
      );
    }
  }

  @override
  Future<ResponseEntity> logout() async {
    try {
      await _grpcGateway.customerStub.logout(LogoutRequest());
      return ResponseEntity(status: ResponseStatus.success);
    } catch (err) {
      return ResponseEntity(
        status: ResponseStatus.error,
        message: 'Failed to logout: ${err.toString()}',
      );
    }
  }

  Future<String> getOrGenerateDeviceId() async {
    final String deviceIdGenerated = Uuid().v4();
    String? savedDeviceId = await _sharedPreferencesGateway.readDeviceId();
    if (savedDeviceId == null || savedDeviceId == 'null') {
      await _sharedPreferencesGateway.saveDeviceId(deviceIdGenerated);
      return deviceIdGenerated;
    }
    return savedDeviceId;
  }

  String buildUserAgent({required String userAgent}) {
    final userAgentString = UserAgentBuilder(
      userAgent: userAgent,
      sdkName: Constants.sdkName,
      sdkVersion: Constants.sdkVersion,
    ).build();
    return userAgentString;
  }
}
