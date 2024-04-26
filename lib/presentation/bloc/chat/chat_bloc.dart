import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/usecase/chat/fetch_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/pick_file_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/send_dialog_message_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/upload_media.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final PickFileUseCase _pickFileUseCase;
  final UploadMediaUseCase _uploadMediaUseCase;
  final ListenToMessagesUseCase _listenToMessagesUseCase;
  final FetchMessagesUseCase _fetchMessagesUseCase;
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(
    this._pickFileUseCase,
    this._uploadMediaUseCase,
    this._listenToMessagesUseCase,
    this._fetchMessagesUseCase,
    this._sendDialogMessageUseCase,
  ) : super(ChatState.initial()) {
    on<UploadMediaEvent>(
      (event, emit) async {
        final file = await _pickFileUseCase();

        if (file != null) {
          final List<DialogMessageEntity> currentMessages = [
            DialogMessageEntity(
              path: file.path,
              messageType: MessageType.user,
              messageCategory: MessageCategory.file,
              requestId: '',
              dialogMessageContent: '',
              peer: Peer(
                id: '',
                type: '',
                name: '',
              ),
            ),
            ...state.dialogMessages
          ];
          emit(state.copyWith(dialogMessages: currentMessages));
          await _uploadMediaUseCase(file: file);
        }
      },
    );
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
              messageCategory: MessageCategory.message,
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
