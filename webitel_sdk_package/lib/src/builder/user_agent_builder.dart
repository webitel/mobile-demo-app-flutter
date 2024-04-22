class UserAgentBuilder {
  late String _appName;
  late String _appVersion;
  late String _osName;
  late String _osVersion;
  late String _deviceModel;

  UserAgentBuilder({
    required String appName,
    required String appVersion,
    required String osName,
    required String osVersion,
    required String deviceModel,
  }) {
    _appName = appName;
    _appVersion = appVersion;
    _osName = osName;
    _osVersion = osVersion;
    _deviceModel = deviceModel;
  }

  UserAgentBuilder setAppName(String appName) {
    _appName = appName;
    return this;
  }

  UserAgentBuilder setAppVersion(String appVersion) {
    _appVersion = appVersion;
    return this;
  }

  UserAgentBuilder setOsName(String osName) {
    _osName = osName;
    return this;
  }

  UserAgentBuilder setOsVersion(String osVersion) {
    _osVersion = osVersion;
    return this;
  }

  UserAgentBuilder setDeviceModel(String deviceModel) {
    _deviceModel = deviceModel;
    return this;
  }

  String build() {
    return '$_appName/$_appVersion ($_osName; $_osVersion; $_deviceModel) grpc-dart';
  }
}
