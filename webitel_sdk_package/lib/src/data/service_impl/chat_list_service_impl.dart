import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/backbone/logger.dart';
import 'package:webitel_sdk_package/src/data/gateway/connect_listener_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/services/chat_list_service.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/messages.pbgrpc.dart';

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
    final chatDialogsRequest = ChatDialogsRequest();
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
