import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/src/backbone/logger.dart';
import 'package:webitel_portal_sdk/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_portal_sdk/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_portal_sdk/src/domain/services/chat_list_service.dart';
import 'package:webitel_portal_sdk/src/generated/chat/messages/dialog.pb.dart'
    as dialog;
import 'package:webitel_portal_sdk/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_portal_sdk/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_portal_sdk/src/generated/portal/messages.pb.dart';

@LazySingleton(as: ChatListService)
class ChatListServiceImpl implements ChatListService {
  final SharedPreferencesGateway _sharedPreferencesGateway;
  final ConnectListenerGateway _connectListenerGateway;
  final uuid = Uuid();
  Logger logger = CustomLogger.getLogger();

  ChatListServiceImpl(
      this._connectListenerGateway, this._sharedPreferencesGateway);

  @override
  Future<void> fetchDialogs() async {
    final id = uuid.v4();
    await _sharedPreferencesGateway.init();
    final chatDialogsRequest = dialog.ChatDialogsRequest();
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatDialogs',
      data: Any.pack(chatDialogsRequest),
      id: id,
    );

    await _connectListenerGateway.sendRequest(request);

    try {
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == id);

      final canUnpackIntoChatList = response.data.canUnpackInto(ChatList());
      if (canUnpackIntoChatList == true) {
        final unpackedDialogMessages = response.data.unpackInto(ChatList());
        _sharedPreferencesGateway.saveToDisk(
            'chatId', unpackedDialogMessages.data.first.id);
      }
    } catch (error, stackTrace) {
      logger.e(error: error, stackTrace: stackTrace, error);
    }
  }
}
