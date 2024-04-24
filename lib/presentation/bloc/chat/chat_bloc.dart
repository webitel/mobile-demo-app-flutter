import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/usecase/chat/fetch_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/send_dialog_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ListenToMessagesUseCase _listenToMessagesUseCase;
  final FetchMessagesUseCase _fetchMessagesUseCase;
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(
    this._listenToMessagesUseCase,
    this._fetchMessagesUseCase,
    this._sendDialogMessageUseCase,
  ) : super(ChatState.initial()) {
    on<FetchMessages>(
      (event, emit) async {
        final messages = await _fetchMessagesUseCase();
        emit(state.copyWith(dialogMessages: messages));
      },
    );
    on<ListenToMessages>(
      (event, emit) async {
        final messagesStream = await _listenToMessagesUseCase();
        await emit.onEach(messagesStream, onData: (message) {
          final List<DialogMessageEntity> currentMessages = [
            DialogMessageEntity(
              requestId: message.requestId,
              messageType: message.messageType,
              dialogMessageContent: message.dialogMessageContent,
              peer: Peer(
                id: message.peer.id,
                type: message.peer.type,
                name: message.peer.name,
              ),
            ),
            ...state.dialogMessages
          ];
          emit(state.copyWith(dialogMessages: currentMessages));
        });
      },
    );

    on<SendDialogMessageEvent>(
      (event, emit) async {
        await _sendDialogMessageUseCase(
          dialogMessageEntity: event.dialogMessageEntity,
        );
      },
    );
  }
}
