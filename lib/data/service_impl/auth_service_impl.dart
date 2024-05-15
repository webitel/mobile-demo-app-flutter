import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  AuthServiceImpl(this._sharedPreferencesGateway);

  @override
  Future<ResponseEntity> login({required Client client}) async {
    await _sharedPreferencesGateway.init();

    final res = await client.login(
      name: 'Volodia Hunkalo',
      sub: 'Account 3',
      issuer: 'https://dev.webitel.com/portal',
      // 'https://paynet.uz/portal',
    );
    return ResponseEntity(
      status: res.status.name == 'success'
          ? ResponseStatus.success
          : ResponseStatus.error,
    );
  }

  @override
  Future<Client> initClient() async {
    final client = await WebitelPortalSdk.instance.initClient(
      url: 'grpcs://dev.webitel.com:443',
      // 'grpcs://test.webitel.me:443',
      appToken:
          '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
      // 'CLboLLKNTa5EP53ySLL0D_eDufMb1LW_LnfhoPb1HAe8xlvgqQW5xpftqfWUmLQt',
    );
    return client;
  }

  @override
  Future<void> logout({required Client client}) async {
    await client.logout();
  }

  @override
  Future<void> registerDevice({
    required Client client,
    required String pushToken,
  }) async {
    await client.registerDevice(pushToken: pushToken);
  }
}
