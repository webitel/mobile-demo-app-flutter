import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:ua_client_hints/ua_client_hints.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  AuthServiceImpl(this._sharedPreferencesGateway);

  @override
  Future<ResponseEntity> login(
      {required String appToken,
      required String baseUrl,
      required String clientToken}) async {
    const uuid = Uuid();
    await _sharedPreferencesGateway.init();

    String? deviceId = await _sharedPreferencesGateway.getFromDisk('deviceId');
    if (deviceId == null) {
      deviceId = uuid.v4();
      await _sharedPreferencesGateway.saveToDisk('deviceId', deviceId);
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final uaData = await userAgentData();
    if (Platform.isAndroid) {
      final userAgentString =
          '${packageInfo.appName}/${packageInfo.version} (${uaData.platform} ${uaData.platformVersion}; ${uaData.model}; ${uaData.device}; ${uaData.architecture})';
      final res = await WebitelPortalSdk.instance.authHandler.login(
        appToken: appToken,
        baseUrl: baseUrl,
        clientToken: clientToken,
        deviceId: deviceId,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        userAgent: userAgentString,
      );
      return ResponseEntity(
        status: res.status.name == 'success'
            ? ResponseStatus.success
            : ResponseStatus.error,
        message: res.message,
      );
    } else if (Platform.isIOS) {
      final userAgentString =
          '${packageInfo.appName}/${packageInfo.version} (${uaData.platform} ${uaData.platformVersion}; ${uaData.model}; ${uaData.device}; ${uaData.architecture})';
      final res = await WebitelPortalSdk.instance.authHandler.login(
        appToken: appToken,
        baseUrl: baseUrl,
        clientToken: clientToken,
        deviceId: deviceId,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        userAgent: userAgentString,
      );
      return ResponseEntity(
        status: res.status.name == 'success'
            ? ResponseStatus.success
            : ResponseStatus.error,
        message: res.message,
      );
    }
    return ResponseEntity(
      status: ResponseStatus.error,
      message: 'Unknown error',
    );
  }
}
