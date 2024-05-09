import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/file_picker_gateway.dart';
import 'package:webitel_sdk/database/database_provider.dart';
import 'package:webitel_sdk/domain/entity/cached_file.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/entity/media_file.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/chat_service.dart';

class ChatServiceImpl implements ChatService {
  final DatabaseProvider _databaseProvider;
  final FilePickerGateway _filePickerGateway;
  late final StreamController<DialogMessageEntity> messagesStreamController;

  ChatServiceImpl(
    this._databaseProvider,
    this._filePickerGateway,
  );

  @override
  Future<File?> pickFile() async {
    File? media = await _filePickerGateway.pickFile();
    if (media != null) {
      return media;
    } else {
      return null;
    }
  }

  @override
  Future<ResponseEntity> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
    required Dialog dialog,
  }) async {
    if (dialogMessageEntity.file != null) {
      final message = await dialog.sendMessage(
        dialogMessageContent: dialogMessageEntity.dialogMessageContent,
        requestId: dialogMessageEntity.requestId,
        mediaType: dialogMessageEntity.file!.type,
        mediaName: dialogMessageEntity.file!.name,
        mediaData: dialogMessageEntity.file!.data,
        messageType: 'media',
      );
      _databaseProvider.saveCachedFile(
        CachedFileEntity(
          id: message.file.id,
          requestId: message.requestId,
          type: message.file.type.toString(),
          path: dialogMessageEntity.file!.path,
          status: CachedFileStatus.sent,
        ),
      );
      return ResponseEntity(
        status: ResponseStatus.success,
        message: message.dialogMessageContent,
      );
    } else if (dialogMessageEntity.file == null) {
      final message = await dialog.sendMessage(
        dialogMessageContent: dialogMessageEntity.dialogMessageContent,
        requestId: dialogMessageEntity.requestId,
        messageType: 'message',
        mediaType: '',
        mediaName: '',
        mediaData: const Stream<List<int>>.empty(),
      );

      return ResponseEntity(
        status: ResponseStatus.success,
        message: message.dialogMessageContent,
      );
    }
    return ResponseEntity(status: ResponseStatus.error, message: '');
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessages({
    required Dialog dialog,
  }) async {
    final messagesFromServer = await dialog.fetchMessages(limit: 20);

    if (messagesFromServer.isNotEmpty) {
      // if is not empty, clear last cached messages and write new ones

      await _databaseProvider.clear();
      await _databaseProvider.writeMessages(dialog);
      // fetch messages by chatId(for now have only one chat)

      final fetchedMessages =
          await _databaseProvider.fetchMessagesByChatId(chatId: '');
      return fetchedMessages;
    } else if (messagesFromServer.isEmpty) {
      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    }
    return [];
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages({
    required Dialog dialog,
  }) async {
    // this is messages stream for all user/operator messages

    final messagesStreamController = StreamController<DialogMessageEntity>();
    dialog.onNewMessage.listen((message) async {
      if (message.file.bytes.isNotEmpty) {
        ByteData byteData =
            ByteData.sublistView(Uint8List.fromList(message.file.bytes));

        final file = await writeToFile(data: byteData, name: message.file.name);

        _databaseProvider.saveCachedFile(
          CachedFileEntity(
            id: message.file.id,
            requestId: message.requestId,
            type: message.file.type.toString(),
            path: file.path,
            status: CachedFileStatus.sent,
          ),
        );
        final messageEntity = DialogMessageEntity(
          file: MediaFileEntity(
            path: file.path,
            id: message.file.id,
            size: message.file.size,
            bytes: message.file.bytes,
            data: const Stream<List<int>>.empty(),
            name: message.file.name,
            type: message.file.type,
            requestId: '',
          ),
          id: message.id,
          dialogMessageContent: message.dialogMessageContent,
          requestId: '',
          messageType: message.sender!.name == 'user'
              ? MessageType.user
              : MessageType.operator,
        );
        _databaseProvider.writeMessageToDatabase(
          message: messageEntity,
        );
        messagesStreamController.add(
          messageEntity,
        );
      } else if (message.file.bytes.isEmpty) {
        final messageEntity = DialogMessageEntity(
          file: MediaFileEntity(
            path: '',
            id: message.file.id,
            size: message.file.size,
            bytes: [],
            data: const Stream<List<int>>.empty(),
            name: message.file.name,
            type: message.file.type,
            requestId: '',
          ),
          id: message.id,
          dialogMessageContent: message.dialogMessageContent,
          requestId: '',
          messageType: message.sender!.name == 'user'
              ? MessageType.user
              : MessageType.operator,
        );
        _databaseProvider.writeMessageToDatabase(
          message: messageEntity,
        );
        messagesStreamController.add(
          messageEntity,
        );
      }
    });

    return messagesStreamController.stream;
  }

  Future<File> writeToFile({
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
