import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:webitel_sdk/backbone/message_type_helper.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/usecase/database/fetch_messages_by_chat_id.dart';
import 'package:webitel_sdk/domain/usecase/database/write_messages_to_database_usecase.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesByChatIdUseCase _fetchMessagesByChatIdUseCase;
  final WriteMessageToDatabaseUseCase _writeMessageToDatabaseUseCase;
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(
    this._sendDialogMessageUseCase,
    this._writeMessageToDatabaseUseCase,
    this._fetchMessagesByChatIdUseCase,
  ) : super(ChatState.initial()) {
    on<FetchUpdatesEvent>(
      (event, emit) async {
        await _writeMessageToDatabaseUseCase(); // To write updates to local storage
        final messages = await _fetchMessagesByChatIdUseCase();
        emit(state.copyWith(dialogMessages: messages));
      },
    );
    on<ListenIncomingOperatorMessagesEvent>(
      (event, emit) async {
        final messagesStreamController =
            await WebitelSdkPackage.instance.eventHandler.listenToMessages();

        await emit.forEach(messagesStreamController.stream, onData: (message) {
          final List<DialogMessageEntity> currentMessages = [
            DialogMessageEntity(
              requestId: message.requestId,
              messageType: categorizeMessageType(message.type!.name),
              dialogMessageContent: message.dialogMessageContent,
              peer: Peer(
                id: message.peer.id,
                type: message.peer.type,
                name: message.peer.name,
              ),
            ),
            ...state.dialogMessages
          ];
          return ChatState(
            dialogMessages: currentMessages,
          );
        });
      },
    );
    on<ListenConnectStatusEvent>((event, emit) async {
      final connectStatusStreamController =
          await WebitelSdkPackage.instance.eventHandler.listenConnectStatus();
      await WebitelSdkPackage.instance.chatListHandler.fetchDialogs();
      final list =
          await WebitelSdkPackage.instance.messageHandler.fetchMessages();
      await emit.onEach(connectStatusStreamController.stream, onData: (status) {
        if (kDebugMode) {
          print(status.status.name);
          print(status.errorMessage);
        }
      });
    });

    on<SendDialogMessageEvent>(
      (event, emit) async {
        await _sendDialogMessageUseCase(
            dialogMessageEntity: event.dialogMessageEntity);
      },
    );
  }
}
