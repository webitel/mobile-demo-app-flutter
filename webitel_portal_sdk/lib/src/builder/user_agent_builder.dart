class UserAgentBuilder {
  late String _userAgent;
  late String _appName;
  late String _appVersion;
  late String _packageName;
  late String _packageVersion;

  UserAgentBuilder({
    required String userAgent,
    required String appName,
    required String appVersion,
    required String packageName,
    required String packageVersion,
  }) {
    _userAgent = userAgent;
    _appName = appName;
    _appVersion = appVersion;
    _packageName = packageName;
    _packageVersion = packageVersion;
  }

  UserAgentBuilder setAppName(String appName) {
    _appName = appName;
    return this;
  }

  UserAgentBuilder setAppVersion(String appVersion) {
    _appVersion = appVersion;
    return this;
  }

  UserAgentBuilder setPackageName(String packageName) {
    _packageName = packageName;
    return this;
  }

  UserAgentBuilder setPackageVersion(String packageVersion) {
    _packageVersion = packageVersion;
    return this;
  }

  UserAgentBuilder setUserAgent(String userAgent) {
    _userAgent = userAgent;
    return this;
  }

  String build() {
    return '$_appName/$_appVersion $_userAgent webitel_portal-sdk/1.0.1 grpc-dart';
  }
}
