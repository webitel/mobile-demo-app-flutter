import 'package:webitel_sdk_package/src/communication/client_initializer.dart';
import 'package:webitel_sdk_package/src/communication/dialog_list_handler.dart';

import 'src/communication/grpc_stream_initializer.dart';
import 'src/injection/dependency_injection.dart';

class WebitelSdkPackage {
  late GrpcStreamInitializer _streamInitializer;
  late DialogListHandler _dialogListHandler;
  late ClientInitializer _clientInitializer;

  static WebitelSdkPackage? _instance;

  WebitelSdkPackage._internal() {
    _initDi();

    _dialogListHandler = DialogListHandler();
    _streamInitializer = GrpcStreamInitializer();
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

  GrpcStreamInitializer get streamInitializer => _streamInitializer;

  DialogListHandler get dialogListHandler => _dialogListHandler;
}
