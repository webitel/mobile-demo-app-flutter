import 'package:webitel_sdk_package/src/backbone/dependency_injection.dart';
import 'package:webitel_sdk_package/src/communication/client_initializer.dart';
import 'package:webitel_sdk_package/src/communication/dialog_list_handler.dart';

import 'src/communication/grpc_stream_initializer.dart';

class WebitelSdkPackage {
  late GrpcStreamInitializer _grpcStreamInitializer;
  late DialogListHandler _dialogListHandler;
  late ClientInitializer _clientInitializer;

  static WebitelSdkPackage? _instance;

  WebitelSdkPackage._internal() {
    _initDi();

    _dialogListHandler = DialogListHandler();
    _grpcStreamInitializer = GrpcStreamInitializer();
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

  GrpcStreamInitializer get grpcStreamInitializer => _grpcStreamInitializer;

  DialogListHandler get dialogListHandler => _dialogListHandler;
}
