import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  AuthServiceImpl(this._sharedPreferencesGateway);

  @override
  Future<ResponseEntity> login({required Client client}) async {
    final res = await client.login(
      name: 'Test name',
      sub: 'Sub 1',
      issuer: 'https://paynet.uz/portal',
    );
    return ResponseEntity(status: ResponseStatus.success);
  }

  @override
  Future<Client> initClient() async {
    final client = await WebitelPortalSdk.instance.initClient(
      url: 'grpcs://test.webitel.me:443',
      appToken:
          'CLboLLKNTa5EP53ySLL0D_eDufMb1LW_LnfhoPb1HAe8xlvgqQW5xpftqfWUmLQt',
    );
    return client;
  }
}
