import 'package:webitel_sdk_package/src/communication/auth_handler.dart';
import 'package:webitel_sdk_package/src/communication/chat_list_handler.dart';
import 'package:webitel_sdk_package/src/communication/event_handler.dart';
import 'package:webitel_sdk_package/src/communication/message_handler.dart';
import 'package:webitel_sdk_package/src/injection/injection.dart';

class WebitelSdkPackage {
  late MessageHandler _messageHandler;
  late EventHandler _eventHandler;
  late AuthHandler _authHandler;
  late ChatListHandler _chatListHandler;

  static WebitelSdkPackage? _instance;

  WebitelSdkPackage._internal() {
    _initDi();
    _chatListHandler = ChatListHandler();
    _authHandler = AuthHandler();
    _eventHandler = EventHandler();
    _messageHandler = MessageHandler();
  }

  static WebitelSdkPackage get instance {
    _instance ??= WebitelSdkPackage._internal();
    return _instance!;
  }

  Future<void> _initDi() async {
    configureDependencies();
  }

  ChatListHandler get chatListHandler => _chatListHandler;

  EventHandler get eventHandler => _eventHandler;

  MessageHandler get messageHandler => _messageHandler;

  AuthHandler get authHandler => _authHandler;
}
