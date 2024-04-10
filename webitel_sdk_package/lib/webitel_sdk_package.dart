import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/communication/dialog_list_handler.dart';

import 'src/communication/initializer.dart';

class WebitelSdkPackage {
  late DialogListHandler _dialogListHandler;
  late Initializer _initializer;
  static WebitelSdkPackage? _instance;

  WebitelSdkPackage._internal() {
    _initDi();
    _dialogListHandler = DialogListHandler();
    _initializer = Initializer();
  }

  static WebitelSdkPackage get instance {
    _instance ??= WebitelSdkPackage._internal();
    return _instance!;
  }

  Future<void> _initDi() async {
    await registerDi();
  }

  DialogListHandler get dialogListHandler => _dialogListHandler;

  Initializer get initializer => _initializer;
}
