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
      name: 'webitel-test',
      sub: 'webitel-test',
      issuer:
      // 'https://dev.webitel.com/portal'
      'https://solva.kz/portal',
      // 'https://paynet.uz/portal',
    );

    return PortalResponse(
      status: res.status.name == 'success'
          ? PortalResponseStatus.success
          : PortalResponseStatus.error,
    );
  }

  @override
  Future<PortalClient> initClient() async {
    final client = await WebitelPortalSdk.instance.initClient(
      loggerLevel: LoggerLevel.debug,
      url:
      // 'grpcs://dev.webitel.com',
      'grpcs://chatbot-webitel.moneyman.kz:443',
      // 'grpcs://chat.paynet.uz:443',
      // 'grpcs://webitel.moneyman.kz:443',
      appToken:
      'zb-zZ33EOZP9wvCkz1_MbUfp1aBGrPKI2uM2JPLO09lH-lUANgSVoXEL_c6bU_lw',
      // 'lcDHQRNK7paCbgYe2CP9W0pC1Q_YqEuL_wW-9Uc7ngIY3KPxZLCOIbthloF9SdbH'

      // '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw'
      // 'CLboLLKNTa5EP53ySLL0D_eDufMb1LW_LnfhoPb1HAe8xlvgqQW5xpftqfWUmLQt'
    );

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
