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
    final message = await dialog.sendMessage(
      dialogMessageContent: dialogMessageEntity.dialogMessageContent,
      requestId: uuid.v4(),
      mediaType: dialogMessageEntity.file!.type,
      mediaName: dialogMessageEntity.file!.name,
      mediaData:
          dialogMessageEntity.file!.data ?? const Stream<List<int>>.empty(),
      messageType: 'media',
    );

    _databaseProvider.saveCachedFile(
      CachedFileEntity(
        id: message.file.id,
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
      dialogMessageContent: dialogMessageEntity.dialogMessageContent,
      requestId: uuid.v4(),
      messageType: 'message',
      mediaData: const Stream<List<int>>.empty(),
    );

    return PortalResponse(
      status: PortalResponseStatus.success,
      message: message.dialogMessageContent,
      //TODO RETURN STATUS CODE
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
              id: message.file.id,
              size: message.file.size,
              data: const Stream.empty(),
              name: message.file.name,
              type: message.file.type,
            ),
            fileName: message.file.name,
            fileId: message.file.id,
            fileType: message.file.type,
            id: message.messageId ?? 0,
            dialogMessageContent: message.dialogMessageContent,
            messageType: message.sender!.name == 'user'
                ? MessageType.user
                : MessageType.operator,
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
      final messageType = message.sender!.name == 'user'
          ? MessageType.user
          : MessageType.operator;
      try {
        final messageEntity = await _processNewMessage(
          dialog,
          DialogMessageEntity(
            file: MediaFileEntity(
              id: message.file.id,
              size: message.file.size,
              data: const Stream.empty(),
              name: message.file.name,
              type: message.file.type,
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
      Dialog dialog, DialogMessageEntity message) async {
    if (message.file!.id.isNotEmpty &&
        message.messageType == MessageType.operator) {
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
        file: MediaFileEntity(
          path: file.path,
          id: message.file!.id,
          size: message.file!.size,
          data: const Stream.empty(),
          name: message.file!.name,
          type: message.file!.type,
        ),
        id: message.id,
        dialogMessageContent: message.dialogMessageContent,
        messageType: MessageType.operator,
      );
    } else {
      final messageEntity = DialogMessageEntity(
        file: MediaFileEntity(
          id: message.file!.id,
          size: message.file!.size,
          data: const Stream.empty(),
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
    final fileStream = dialog.downloadFile(fileId: message.file.id);
    List<int> bytesList = [];

    await for (var bytes in fileStream) {
      int chunkSize = bytes.bytes.length;
      if (chunkSize > 0) {
        if (kDebugMode) {
          print('Received chunk of $chunkSize bytes');
        }
        bytesList.addAll(bytes.bytes);
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
}
