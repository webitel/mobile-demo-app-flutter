import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/communication/call_handler.dart';
import 'package:webitel_sdk_package/src/communication/dialog_handler.dart';
import 'package:webitel_sdk_package/src/communication/message_handler.dart';

import 'src/communication/initializer.dart';

class WebitelSdkPackage {
  late DialogHandler _dialogHandler;
  late MessageHandler _messageHandler;
  late CallHandler _callHandler;
  late Initializer _initializer;

  static WebitelSdkPackage? _instance;

  WebitelSdkPackage._internal() {
    initDi();
    _dialogHandler = DialogHandler();
    _messageHandler = MessageHandler();
    _callHandler = CallHandler();
    _initializer = Initializer();
  }

  static WebitelSdkPackage get instance {
    _instance ??= WebitelSdkPackage._internal();
    return _instance!;
  }

  Future<void> initDi() async {
    await registerDi();
  }

  DialogHandler get dialogHandler => _dialogHandler;

  MessageHandler get messageHandler => _messageHandler;

  CallHandler get callHandler => _callHandler;

  Initializer get initializer => _initializer;
}
