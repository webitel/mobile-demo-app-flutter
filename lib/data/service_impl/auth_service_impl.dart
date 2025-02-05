import 'dart:async';

import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  AuthServiceImpl(this._sharedPreferencesGateway);

  final errorController = StreamController<CallError>.broadcast();

  @override
  Future<PortalResponse> login({required PortalClient client}) async {
    await _sharedPreferencesGateway.init();

    final res = await client.login(
        name: 'webitel-test', sub: 'webitel-test', issuer: 'test');

    return PortalResponse(
      status: res.status.name == 'success'
          ? PortalResponseStatus.success
          : PortalResponseStatus.error,
    );
  }

  @override
  Future<PortalClient> initClient() async {
    final client = await WebitelPortalSdk.instance.initClient(
        loggerLevel: LoggerLevel.debug, url: 'test', appToken: 'test');

    return client;
  }

  @override
  Future<void> logout({required PortalClient client}) async {
    await client.logout();
  }

  @override
  Future<void> registerDevice({
    required PortalClient client,
    required String pushToken,
  }) async {
    await client.registerDevice(pushToken: pushToken);
  }

  @override
  Future<Stream<CallError>> listenToError({
    required PortalClient client,
  }) async {
    final channel = await client.getChannel();
    channel.onError.listen((error) {
      errorController.add(
        CallError(
          statusCode: error.statusCode,
          errorMessage: error.errorMessage,
        ),
      );
    });
    return errorController.stream;
  }
}
