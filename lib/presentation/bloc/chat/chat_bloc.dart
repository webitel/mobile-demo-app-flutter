import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(this._sendDialogMessageUseCase) : super(ChatState.initial()) {
    const uuid = Uuid();
    on<ListenIncomingOperatorMessages>(
      (event, emit) async {
        final stream = await WebitelSdkPackage
            .instance.dialogListHandler.dialogMessageHandler
            .listenToOperatorMessages(id: uuid.v4());
        final bool = await WebitelSdkPackage.instance.dialogListHandler
            .listenConnectStatus();

        await emit.forEach(stream, onData: (message) {
          if (kDebugMode) {
            print(message);
          }
          final List<DialogMessageEntity> currentMessages =
              state.dialogMessages;
          final List<DialogMessageEntity> updatedMessages =
              List.from(currentMessages)
                ..add(
                  DialogMessageEntity(
                    messageType: message.type!.name == 'user'
                        ? MessageType.user
                        : MessageType.operator,
                    dialogMessageContent: message.dialogMessageContent,
                    peer: Peer(
                      id: message.peer.id,
                      type: message.peer.type,
                      name: message.peer.name,
                    ),
                  ),
                );
          return ChatState(
            sendDialogMessageStatus: SendDialogMessageStatus.sent,
            dialogMessages: updatedMessages,
          );
        });
      },
    );

    on<SendDialogMessageEvent>(
      (event, emit) async {
        final message = await _sendDialogMessageUseCase(
            dialogMessageEntity: event.dialogMessageEntity);
        final List<DialogMessageEntity> currentMessages = state.dialogMessages;
        final List<DialogMessageEntity> updatedMessages =
            List.from(currentMessages)
              ..add(
                DialogMessageEntity(
                  dialogMessageContent: message.dialogMessageContent,
                  messageType: message.messageType!.name == 'user'
                      ? MessageType.user
                      : MessageType.operator,
                  peer: Peer(
                    id: message.peer.id,
                    type: message.peer.type,
                    name: message.peer.name,
                  ),
                ),
              );
        emit(state.copyWith(dialogMessages: updatedMessages));
      },
    );
  }
}
