import 'package:webitel_sdk_package/src/communication/dialog_call_handler.dart';
import 'package:webitel_sdk_package/src/communication/dialog_message_handler.dart';

class DialogListHandler {
  late DialogCallHandler dialogCallHandler;
  late DialogMessageHandler dialogMessageHandler;

  DialogListHandler() {
    dialogCallHandler = DialogCallHandler();
    dialogMessageHandler = DialogMessageHandler();
  }
}
