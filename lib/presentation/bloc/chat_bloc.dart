import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:webitel_sdk/domain/entity/dialog_message.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(this._sendDialogMessageUseCase) : super(ChatState.initial()) {
    on<SendDialogMessageEvent>(
      (event, emit) async {
        final message = await _sendDialogMessageUseCase(
            dialogMessageEntity: event.dialogMessageEntity);

        final List<DialogMessageEntity> currentMessages = state.dialogMessages;

        final List<DialogMessageEntity> updatedMessages =
            List.from(currentMessages)..add(message);

        emit(state.copyWith(dialogMessages: updatedMessages));
      },
      transformer: sequential(),
    );
  }
}
