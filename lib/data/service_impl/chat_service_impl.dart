import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/file_picker_gateway.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/entity/cached_file.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/media_file.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

import '../../domain/entity/msg_type.dart';

class ChatServiceImpl implements ChatService {
  final DatabaseProvider _databaseProvider;
  final FilePickerGateway _filePickerGateway;

  ChatServiceImpl(
    this._databaseProvider,
    this._filePickerGateway,
  );

  final uuid = const Uuid();

  @override
  Future<File?> pickFile() async {
    try {
      return await _filePickerGateway.pickFile();
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  @override
  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  @override
  Future<PortalResponse> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
    required Dialog dialog,
  }) async {
    try {
      if (dialogMessageEntity.file != null) {
        return await _sendMessageWithFile(dialogMessageEntity, dialog);
      } else {
        return await _sendMessageWithoutFile(dialogMessageEntity, dialog);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return PortalResponse(
        status: PortalResponseStatus.error,
        message: e.toString(),
      );
    }
  }

  Future<PortalResponse> _sendMessageWithFile(
    DialogMessageEntity dialogMessageEntity,
    Dialog dialog,
  ) async {
    // Step 1: Upload the file
    final upload = dialog.uploadFile(
      mediaType: dialogMessageEntity.file!.type,
      mediaName: dialogMessageEntity.file!.name,
      file: dialogMessageEntity.file!.file!,
    );

    // Step 2: Wait for the upload to complete and get file metadata
    UploadResponse? fileResponse;

    try {
      await for (final progress in upload.onProgress.stream) {
        if (kDebugMode) {
          print('Progress: ${progress.progress?.progressSize} bytes uploaded');
        }
        if (progress.id != null && progress.id!.isNotEmpty) {
          fileResponse = progress;
          break; // File upload completed
        }
      }
    } catch (e) {
      debugPrint('Error during file upload: $e');
    }

    // Check if the file upload completed successfully
    if (fileResponse == null) {
      return PortalResponse(
        status: PortalResponseStatus.error,
        message: 'File upload failed.',
      );
    }

    if (kDebugMode) {
      print(
          'File uploaded: ${fileResponse.name}, id: ${fileResponse.id}, type: ${fileResponse.type}');
    }

    // Step 3: Send the message with the uploaded file's metadata
    final message = await dialog.sendMessage(
      content: dialogMessageEntity.dialogMessageContent,
      requestId: uuid.v4(),
      uploadFile: UploadFile(
        id: fileResponse.id ?? '',
        name: fileResponse.name ?? '',
        type: fileResponse.type ?? '',
      ),
    );

    // Step 4: Save the file metadata to cache
    _databaseProvider.saveCachedFile(
      CachedFileEntity(
        id: message.file.id ?? '',
        type: message.file.type.toString(),
        path: dialogMessageEntity.file!.path ?? '',
        status: CachedFileStatus.sent,
      ),
    );

    return PortalResponse(
      status: PortalResponseStatus.success,
      message: message.dialogMessageContent,
    );
  }

  Future<PortalResponse> _sendMessageWithoutFile(
    DialogMessageEntity dialogMessageEntity,
    Dialog dialog,
  ) async {
    final message = await dialog.sendMessage(
      content: dialogMessageEntity.dialogMessageContent,
      requestId: uuid.v4(),
    );

    return PortalResponse(
      status: PortalResponseStatus.success,
      message: message.dialogMessageContent,
      // TODO: RETURN STATUS CODE IF NEEDED
    );
  }

  @override
  Future<List<DialogMessageEntity>> fetchPaginationMessages({
    required Dialog dialog,
    required int limit,
    required int offset,
  }) async {
    final messagesFromServer =
        await dialog.fetchMessages(limit: limit, offset: offset);
    return messagesFromServer
        .map(
          (message) => DialogMessageEntity(
            file: MediaFileEntity(
              id: message.file.id ?? '',
              size: message.file.size ?? 0,
              name: message.file.name ?? '',
              type: message.file.type ?? '',
            ),
            fileName: message.file.name,
            fileId: message.file.id,
            fileType: message.file.type,
            id: message.messageId ?? 0,
            dialogMessageContent: message.dialogMessageContent,
            messageType: message.sender!.name == 'user'
                ? MsgType.user
                : MsgType.operator,
          ),
        )
        .toList();
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessages({
    required Dialog dialog,
  }) async {
    final messagesFromServer = await dialog.fetchMessages(limit: 20);

    if (messagesFromServer.isNotEmpty) {
      await _databaseProvider.clear();
      await _databaseProvider.writeMessages(dialog);

      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    } else {
      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    }
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages({
    required Dialog dialog,
  }) async {
    final messagesStreamController = StreamController<DialogMessageEntity>();

    dialog.onNewMessage.listen((message) async {
      final messageType =
          message.sender!.name == 'user' ? MsgType.user : MsgType.operator;

      try {
        Keyboard? keyboard;
        if (message.keyboard!.buttons.isNotEmpty) {
          keyboard = Keyboard(
            buttons: message.keyboard!.buttons.map((buttonRow) {
              return buttonRow.map((button) {
                return Button(
                  text: button.text,
                  code: button.code,
                  url: button.url,
                );
              }).toList();
            }).toList(),
          );
        }

        final messageEntity = await _processNewMessage(
          dialog,
          DialogMessageEntity(
            keyboard: keyboard,
            file: MediaFileEntity(
              id: message.file.id ?? '',
              size: message.file.size ?? 0,
              name: message.file.name ?? '',
              type: message.file.type ?? '',
            ),
            fileName: message.file.name,
            fileId: message.file.id,
            fileType: message.file.type,
            id: message.messageId ?? 0,
            dialogMessageContent: message.dialogMessageContent,
            messageType: messageType,
          ),
        );
        messagesStreamController.add(messageEntity);
      } catch (e) {
        debugPrint('Error processing new message: $e');
      }
    });

    return messagesStreamController.stream;
  }

  Future<DialogMessageEntity> _processNewMessage(
    Dialog dialog,
    DialogMessageEntity message,
  ) async {
    if (message.file!.id.isNotEmpty &&
        message.messageType == MsgType.operator) {
      final file = await _downloadFile(dialog, message);
      _databaseProvider.saveCachedFile(
        CachedFileEntity(
          id: message.file!.id,
          type: message.file!.type.toString(),
          path: file.path,
          status: CachedFileStatus.sent,
        ),
      );

      return DialogMessageEntity(
        keyboard: message.keyboard,
        file: MediaFileEntity(
          path: file.path,
          id: message.file!.id,
          size: message.file!.size,
          name: message.file!.name,
          type: message.file!.type,
        ),
        id: message.id,
        dialogMessageContent: message.dialogMessageContent,
        messageType: MsgType.operator,
      );
    } else {
      final messageEntity = DialogMessageEntity(
        keyboard: message.keyboard,
        file: MediaFileEntity(
          id: message.file!.id,
          size: message.file!.size,
          name: message.file!.name,
          type: message.file!.type,
        ),
        id: message.id,
        dialogMessageContent: message.dialogMessageContent,
        messageType: message.messageType,
      );
      _databaseProvider.writeMessageToDatabase(message: messageEntity);

      return messageEntity;
    }
  }

  Future<File> _downloadFile(Dialog dialog, dynamic message) async {
    final download = dialog.downloadFile(fileId: message.file.id);

    List<int> bytesList = [];
    bool isPaused = false;

    await for (var bytes in download.onData.stream) {
      int chunkSize = bytes.bytes?.length ?? 0;
      if (chunkSize > 0) {
        if (kDebugMode) {
          print('Received chunk of $chunkSize bytes');
        }
        bytesList.addAll(bytes.bytes ?? []);

        // Imitate pausing the download after the first chunk
        if (!isPaused) {
          isPaused = true;
          await download.pause();

          if (kDebugMode) {
            print('Download paused');
          }

          // Wait for a short delay before resuming the download
          await Future.delayed(const Duration(seconds: 5));

          // Resume the download
          await download.resume();
        }
      } else {
        if (kDebugMode) {
          print('Received chunk of 0 bytes, skipping');
        }
      }
    }

    ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytesList));

    return await _writeToFile(data: byteData, name: message.file.name);
  }

  Future<File> _writeToFile({
    required ByteData data,
    required String name,
  }) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/$name';

    return File(filePath).writeAsBytes(
      buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      ),
    );
  }

  // Future<File> _downloadFile(Dialog dialog, dynamic message) async {
  //   final fileStream = dialog.downloadFile(fileId: message.file.id);
  //   List<int> bytesList = [];
  //
  //   await for (var bytes in fileStream.onData) {
  //     int chunkSize = bytes.bytes.length;
  //     if (chunkSize > 0) {
  //       if (kDebugMode) {
  //         print('Received chunk of $chunkSize bytes');
  //       }
  //       bytesList.addAll(bytes.bytes);
  //     } else {
  //       if (kDebugMode) {
  //         print('Received chunk of 0 bytes, skipping');
  //       }
  //     }
  //   }
  //
  //   ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytesList));
  //
  //   return await _writeToFile(data: byteData, name: message.file.name);
  // }
  //
  // Future<File> _writeToFile({
  //   required ByteData data,
  //   required String name,
  // }) async {
  //   final buffer = data.buffer;
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //   var filePath = '$tempPath/$name';
  //
  //   return File(filePath).writeAsBytes(
  //     buffer.asUint8List(
  //       data.offsetInBytes,
  //       data.lengthInBytes,
  //     ),
  //   );
  // }

  @override
  Future<PortalResponse> sendPostback({
    required Postback postback,
    required Dialog dialog,
  }) async {
    final requestId = uuid.v4();
    final res = await dialog.sendPostback(
      postback: postback,
      requestId: requestId,
    );

    return PortalResponse(status: PortalResponseStatus.success);
  }
}
