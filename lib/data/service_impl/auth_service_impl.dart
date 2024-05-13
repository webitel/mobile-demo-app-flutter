import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  AuthServiceImpl(this._sharedPreferencesGateway);

  @override
  Future<Client> login() async {
    await _sharedPreferencesGateway.init();

    final client = await WebitelPortalSdk.instance.initClient(
      url: 'grpcs://test.webitel.me:443',
      appToken:
          'CLboLLKNTa5EP53ySLL0D_eDufMb1LW_LnfhoPb1HAe8xlvgqQW5xpftqfWUmLQt',
    );

    final res = await client.login(
      name: 'Test name',
      sub: 'Sub 1',
      issuer: 'https://paynet.uz/portal',
    );
    return client;
  }
}
