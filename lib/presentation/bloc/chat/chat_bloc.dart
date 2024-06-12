import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/media_file.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;

  ChatBloc(this.chatService) : super(ChatState.initial()) {
    on<ClearImageFromStateEvent>((event, emit) async {
      emit(state.copyWith(selectedFile: File('')));
    });

    on<FetchDialogs>((event, emit) async {
      final serviceDialog = await event.client.chat.fetchServiceDialog();
      emit(state.copyWith(dialog: serviceDialog));

      if (serviceDialog.id.isNotEmpty) {
        add(ListenToMessages());
        add(FetchMessages());
      }
    });

    on<UploadFileEvent>((event, emit) async {
      final file = await chatService.pickFile();

      if (file != null) {
        emit(state.copyWith(selectedFile: file));
      }
    });

    on<SendPostbackEvent>((event, emit) async {
      final res = await chatService.sendPostback(
        postback: event.postback,
        dialog: state.dialog!,
      );
      if (kDebugMode) {
        print(res);
      }
    });

    on<UploadImageEvent>((event, emit) async {
      final file = await chatService.pickImage();

      if (file != null) {
        emit(state.copyWith(selectedFile: file));
      }
    });

    on<SendDialogMessageEvent>((event, emit) async {
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
        final message = await chatService.sendDialogMessage(
          dialogMessageEntity: DialogMessageEntity(
            dialogMessageContent:
                event.dialogMessageEntity.dialogMessageContent,
            file: MediaFileEntity(
              id: '',
              size: 0,
              bytes: [],
              data: controller.stream,
              path: path,
              name: fileName,
              type: mimeType,
            ),
            id: 0,
          ),
          dialog: state.dialog!,
        );
        if (message.statusCode == '401') {
          if (kDebugMode) {
            print(message.statusCode); //TODO
          }
        }
        add(ClearImageFromStateEvent());
      } else {
        final message = await chatService.sendDialogMessage(
          dialogMessageEntity: DialogMessageEntity(
            dialogMessageContent:
                event.dialogMessageEntity.dialogMessageContent,
            id: 0,
          ),
          dialog: state.dialog!,
        );
        if (message.statusCode == '401') {
          if (kDebugMode) {
            print(message.statusCode); //TODO
          }
        }
        add(ClearImageFromStateEvent());
      }
    });

    on<FetchMessages>((event, emit) async {
      final messages = await chatService.fetchMessages(dialog: state.dialog!);
      emit(state.copyWith(dialogMessages: messages));
    });

    on<FetchPaginationMessages>((event, emit) async {
      final paginationMessages = await chatService.fetchPaginationMessages(
        dialog: state.dialog!,
        limit: 20,
        offset: state.dialogMessages.last.id,
      );
      final updatedMessages = [
        ...state.dialogMessages,
        ...paginationMessages,
      ];
      emit(state.copyWith(dialogMessages: updatedMessages));
    });

    on<ListenToMessages>((event, emit) async {
      final messagesStream =
          await chatService.listenToMessages(dialog: state.dialog!);
      await emit.onEach<DialogMessageEntity>(messagesStream, onData: (message) {
        if (message.file?.name.isNotEmpty ?? false) {
          add(FetchMessages());
        } else if (message.file != null &&
            message.file!.path != null &&
            message.file!.path!.isNotEmpty) {
          final currentMessages = [
            DialogMessageEntity(
              keyboard: message.keyboard!.buttons.isNotEmpty
                  ? message.keyboard
                  : null,
              path: message.file!.path,
              fileId: message.file!.id,
              messageType: message.messageType,
              dialogMessageContent: message.dialogMessageContent,
              id: message.id,
            ),
            ...state.dialogMessages,
          ];
          emit(state.copyWith(dialogMessages: currentMessages));
        } else {
          final currentMessages = [
            DialogMessageEntity(
              keyboard: message.keyboard,
              messageType: message.messageType,
              dialogMessageContent: message.dialogMessageContent,
              id: message.id,
            ),
            ...state.dialogMessages,
          ];
          emit(state.copyWith(dialogMessages: currentMessages));
        }
      });
    });
  }
}
