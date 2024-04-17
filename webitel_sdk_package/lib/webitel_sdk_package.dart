import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/communication/auth_handler.dart';
import 'package:webitel_sdk_package/src/communication/client_initializer.dart';
import 'package:webitel_sdk_package/src/communication/dialog_list_handler.dart';

class WebitelSdkPackage {
  late DialogListHandler _dialogListHandler;
  late ClientInitializer _clientInitializer;
  late AuthHandler _authHandler;

  static WebitelSdkPackage? _instance;

  WebitelSdkPackage._internal() {
    _initDi();
    _authHandler = AuthHandler();
    _dialogListHandler = DialogListHandler();

    _clientInitializer = ClientInitializer();
  }

  static WebitelSdkPackage get instance {
    _instance ??= WebitelSdkPackage._internal();
    return _instance!;
  }

  Future<void> _initDi() async {
    await registerDi();
  }

  ClientInitializer get clientInitializer => _clientInitializer;

  AuthHandler get authHandler => _authHandler;

  DialogListHandler get dialogListHandler => _dialogListHandler;
}
