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
    final requestId = uuid.v4();
    logger.i('Initiating fetch for chat dialogs with request ID: $requestId');

    await _sharedPreferencesGateway.init();
    final chatDialogsRequest = dialog.ChatDialogsRequest();
    final request = portal.Request(
      path: '/webitel.portal.ChatMessages/ChatDialogs',
      data: Any.pack(chatDialogsRequest),
      id: requestId,
    );

    logger.i('Sending request to fetch chat dialogs');
    await _connectListenerGateway.sendRequest(request);

    try {
      final response = await _connectListenerGateway.responseStream
          .firstWhere((response) => response.id == requestId);

      logger.i('Received response for chat dialogs request ID: $requestId');
      if (response.data.canUnpackInto(ChatList())) {
        final unpackedDialogMessages = response.data.unpackInto(ChatList());
        if (unpackedDialogMessages.data.isNotEmpty) {
          logger.i(
              'Successfully unpacked chat dialogs, saving first chat ID to preferences');
          _sharedPreferencesGateway.saveToDisk(
              'chatId', unpackedDialogMessages.data.first.id);
        } else {
          logger.w('No chat dialogs were returned in the response');
        }
      } else {
        logger.e('Failed to unpack chat list for request ID: $requestId');
      }
    } catch (err, stackTrace) {
      logger.e('Error fetching chat dialogs with request ID: $requestId',
          error: err, stackTrace: stackTrace);
    }
  }
}
