import 'package:package_info_plus/package_info_plus.dart';
import 'package:ua_client_hints/ua_client_hints.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  AuthServiceImpl(this._sharedPreferencesGateway);

  @override
  Future<ResponseEntity> login() async {
    await _sharedPreferencesGateway.init();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final uaData = await userAgentData();
    final res = await WebitelPortalSdk.instance.login(
      appToken:
          'CLboLLKNTa5EP53ySLL0D_eDufMb1LW_LnfhoPb1HAe8xlvgqQW5xpftqfWUmLQt',
      url: 'grpcs://test.webitel.me:443',
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      platform: uaData.platform,
      platformVersion: uaData.platformVersion,
      model: uaData.model,
      device: uaData.device,
      architecture: uaData.architecture,
      name: 'Test name',
      sub: 'Sub 1',
      issuer: 'https://paynet.uz/portal',
    );
    return ResponseEntity(
      status: res.status.name == 'success'
          ? ResponseStatus.success
          : ResponseStatus.error,
      message: res.message,
    );
    return ResponseEntity(
      status: ResponseStatus.error,
      message: 'Unknown error',
    );
  }
}
