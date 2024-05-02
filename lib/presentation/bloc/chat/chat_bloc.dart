import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/media_file.dart';
import 'package:webitel_sdk/domain/usecase/chat/fetch_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/listen_to_messages_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/pick_file_usecase.dart';
import 'package:webitel_sdk/domain/usecase/chat/send_dialog_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final PickFileUseCase _pickFileUseCase;
  final ListenToMessagesUseCase _listenToMessagesUseCase;
  final FetchMessagesUseCase _fetchMessagesUseCase;
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(
    this._pickFileUseCase,
    this._listenToMessagesUseCase,
    this._fetchMessagesUseCase,
    this._sendDialogMessageUseCase,
  ) : super(ChatState.initial()) {
    on<ClearImageFromStateEvent>(
      (event, emit) async {
        emit(
          state.copyWith(
            selectedFile: File(''),
          ),
        );
      },
    );
    on<UploadMediaEvent>(
      (event, emit) async {
        final file = await _pickFileUseCase();

        if (file != null) {
          emit(
            state.copyWith(
              selectedFile: file,
            ),
          );
        }
      },
    );
    on<SendDialogMessageEvent>(
      (event, emit) async {
        if (state.selectedFile.path.isNotEmpty) {
          var byteStream = state.selectedFile.openRead();
          int totalFileSize = await state.selectedFile.length();
          int bytesUploaded = 0;

          var controller = StreamController<List<int>>();

          byteStream.listen(
            (data) {
              controller.add(data);
              bytesUploaded += data.length;
              double progress = bytesUploaded / totalFileSize * 100;
              if (kDebugMode) {
                print('Progress: $progress%');
              }
            },
            onDone: () {
              controller.close();
            },
            onError: (error) {
              controller.addError(error);
              controller.close();
            },
          );

          String mimeType = lookupMimeType(state.selectedFile.path) ??
              'application/octet-stream';
          String fileName = state.selectedFile.path.split('/').last;
          String path = state.selectedFile.path;
          await _sendDialogMessageUseCase(
            dialogMessageEntity: DialogMessageEntity(
              requestId: event.dialogMessageEntity.requestId,
              dialogMessageContent:
                  event.dialogMessageEntity.dialogMessageContent,
              peer: Peer(id: '', type: 'chat', name: ''),
              file: MediaFileEntity(
                id: '',
                size: 0,
                bytes: [],
                data: controller.stream,
                // Use the controlled stream
                path: path,
                name: fileName,
                type: mimeType,
                requestId: event.dialogMessageEntity.requestId,
              ),
              id: '',
            ),
          );
          add(ClearImageFromStateEvent());
        } else {
          await _sendDialogMessageUseCase(
            dialogMessageEntity: DialogMessageEntity(
              requestId: event.dialogMessageEntity.requestId,
              dialogMessageContent:
                  event.dialogMessageEntity.dialogMessageContent,
              peer: Peer(
                id: '',
                type: 'chat',
                name: '',
              ),
              id: '',
            ),
          );
          add(ClearImageFromStateEvent());
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
          if (message.file != null) {
            add(FetchMessages());
          } else {
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
                id: message.id,
              ),
              ...state.dialogMessages
            ];
            emit(
              state.copyWith(
                dialogMessages: currentMessages,
              ),
            );
          }
        });
      },
    );
  }
}
