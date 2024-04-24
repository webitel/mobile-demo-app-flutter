import 'package:webitel_portal_sdk/src/communication/auth_handler.dart';
import 'package:webitel_portal_sdk/src/communication/chat_list_handler.dart';
import 'package:webitel_portal_sdk/src/communication/media_handler.dart';
import 'package:webitel_portal_sdk/src/communication/message_handler.dart';
import 'package:webitel_portal_sdk/src/communication/portal_handler.dart';
import 'package:webitel_portal_sdk/src/injection/injection.dart';

class WebitelPortalSdk {
  late MediaHandler _mediaHandler;
  late PortalHandler _portalHandler;
  late MessageHandler _messageHandler;
  late AuthHandler _authHandler;
  late ChatListHandler _chatListHandler;

  static WebitelPortalSdk? _instance;

  WebitelPortalSdk._internal() {
    _initDi();
    _mediaHandler = MediaHandler();
    _portalHandler = PortalHandler();
    _chatListHandler = ChatListHandler();
    _authHandler = AuthHandler();
    _messageHandler = MessageHandler();
  }

  static WebitelPortalSdk get instance {
    _instance ??= WebitelPortalSdk._internal();
    return _instance!;
  }

  Future<void> _initDi() async {
    configureDependencies();
  }

  MediaHandler get mediaHandler => _mediaHandler;

  PortalHandler get portalHandler => _portalHandler;

  ChatListHandler get chatListHandler => _chatListHandler;

  MessageHandler get messageHandler => _messageHandler;

  AuthHandler get authHandler => _authHandler;
}
