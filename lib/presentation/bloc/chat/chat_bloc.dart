import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:webitel_sdk/backbone/message_type_helper.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(this._sendDialogMessageUseCase) : super(ChatState.initial()) {
    on<ListenIncomingOperatorMessages>(
      (event, emit) async {
        final stream = await WebitelSdkPackage
            .instance.dialogListHandler.dialogMessageHandler
            .listenToMessages();

        await emit.forEach(stream, onData: (message) {
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

    on<SendDialogMessageEvent>(
      (event, emit) async {
        await _sendDialogMessageUseCase(
            dialogMessageEntity: event.dialogMessageEntity);
      },
    );
  }
}
