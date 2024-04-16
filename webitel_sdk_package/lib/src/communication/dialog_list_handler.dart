import 'package:webitel_sdk_package/src/backbone/injection/dependency_injection.dart';
import 'package:webitel_sdk_package/src/communication/dialog_call_handler.dart';
import 'package:webitel_sdk_package/src/communication/dialog_message_handler.dart';
import 'package:webitel_sdk_package/src/domain/entities/connect_status.dart';
import 'package:webitel_sdk_package/src/domain/usecase/grpc_chat/listen_connect_status_usecase.dart';

class DialogListHandler {
  late DialogCallHandler dialogCallHandler;
  late DialogMessageHandler dialogMessageHandler;
  late ListenConnectStatusUseCase _listenConnectStatusUseCase;

  DialogListHandler() {
    _listenConnectStatusUseCase = locator.get<ListenConnectStatusUseCase>(
        instanceName: "ListenConnectStatusUseCase");

    dialogCallHandler = DialogCallHandler();
    dialogMessageHandler = DialogMessageHandler();
  }

  Future<Stream<ConnectStreamStatus>> listenConnectStatus() async {
    final connectStreamStatusListener = await _listenConnectStatusUseCase();
    return connectStreamStatusListener;
  }
}
