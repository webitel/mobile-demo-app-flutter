import 'package:uuid/uuid.dart';
import 'package:webitel_sdk/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk/domain/service/local_storage_service.dart';

class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferencesGateway _sharedPreferencesGateway;

  LocalStorageServiceImpl(this._sharedPreferencesGateway);

  @override
  Future<String> fetchDeviceId() async {
    const uuid = Uuid();
    await _sharedPreferencesGateway.init();
    final deviceId = await _sharedPreferencesGateway.getFromDisk('deviceId');
    if (deviceId == 'null') {
      await _sharedPreferencesGateway.saveToDisk('deviceId', uuid.v4());
      final deviceId = await _sharedPreferencesGateway.getFromDisk('deviceId');
      if (deviceId != null) {
        return deviceId;
      }
    } else {
      return deviceId!;
    }
    return '';
  }
}
