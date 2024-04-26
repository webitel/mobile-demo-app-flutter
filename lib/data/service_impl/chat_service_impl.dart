import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/data/gateway/file_picker_gateway.dart';
import 'package:webitel_sdk/database/database_provider.dart';
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
  Future<MediaFileEntity> uploadMedia({required File file}) async {
    try {
      // int totalBytes = await media.length();
      // int bytesUploaded = 0;
      //
      // media.openRead().listen((List<int> chunk) {
      //   bytesUploaded += chunk.length;
      //
      //   double percentage = (bytesUploaded / totalBytes) * 100;
      //   print(chunk.length);
      // });

      String mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      String fileName = file.path.split('/').last;

      final res = await WebitelPortalSdk.instance.mediaHandler.uploadMedia(
        type: mimeType,
        name: fileName,
        data: file.openRead(),
      );
      return MediaFileEntity(
        name: res.name,
        type: res.type,
        id: res.id,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error uploading file: $error');
      }
      return MediaFileEntity(
        name: error.toString(),
        type: '',
        id: '',
      );
    }
  }

  @override
  Future<ResponseEntity> sendDialogMessage({
    required DialogMessageEntity dialogMessageEntity,
  }) async {
    final message = await WebitelPortalSdk.instance.messageHandler.sendMessage(
      dialogMessageContent: dialogMessageEntity.dialogMessageContent,
      requestId: dialogMessageEntity.requestId,
      peerType: dialogMessageEntity.peer.type,
      peerName: dialogMessageEntity.peer.name,
      peerId: dialogMessageEntity.peer.id,
    );
    return ResponseEntity(
        status: ResponseStatus.success, message: message.dialogMessageContent);
  }

  @override
  Future<List<DialogMessageEntity>> fetchMessages() async {
    await WebitelPortalSdk.instance.chatListHandler.fetchDialogs();
    //Checking if messages from server is not empty, if empty - load last cached messages in database

    final messagesFromServer =
        await WebitelPortalSdk.instance.messageHandler.fetchMessages(limit: 20);
    if (messagesFromServer.isNotEmpty) {
      // if is not empty, clear last cached messages and write new ones

      await _databaseProvider.clear();
      await _databaseProvider.writeMessages();
      // fetch messages by chatId(for now have only one chat)

      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    } else if (messagesFromServer.isEmpty) {
      return await _databaseProvider.fetchMessagesByChatId(chatId: '');
    }
    return [];
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToMessages() async {
    // this is messages stream for all user/operator messages
    final messagesStream =
        await WebitelPortalSdk.instance.messageHandler.listenToMessages();

    final messagesStreamController = StreamController<DialogMessageEntity>();

    messagesStream.stream.listen((message) {
      final messageEntity = DialogMessageEntity(
        dialogMessageContent: message.dialogMessageContent,
        peer: Peer(id: '', type: '', name: ''),
        requestId: message.requestId,
        messageType: message.type!.name == 'user'
            ? MessageType.user
            : MessageType.operator,
      );

      _databaseProvider.writeMessageToDatabase(
        message: messageEntity,
      );
      messagesStreamController.add(
        messageEntity,
      );
    });

    return messagesStreamController.stream;
  }
}

// @override
// Future<void> uploadMedia() async {
//   File? media = await _filePickerGateway.pickFile();
//   if (media != null) {
//     try {
//       String mimeType =
//           lookupMimeType(media.path) ?? 'application/octet-stream';
//       String fileName = media.path.split('/').last;
//       int totalFileSize = await media.length();
//       var byteStream = media.openRead();
//       int bytesUploaded = 0;
//       int chunkSize = 512 * 1024;
//
//       StreamTransformer<List<int>, List<int>> chunkTransformer =
//       StreamTransformer<List<int>, List<int>>.fromHandlers(
//         handleData: (List<int> data, EventSink<List<int>> sink) {
//           sink.add(data);
//           bytesUploaded += data.length;
//           double progress = bytesUploaded / totalFileSize * 100;
//           print('Progress: $progress%');
//         },
//         handleDone: (EventSink<List<int>> sink) {
//           sink.close();
//         },
//       );
//
//       var chunkedStream = byteStream.transform(chunkTransformer);
//       await WebitelPortalSdk.instance.mediaHandler.uploadMedia(
//         type: mimeType,
//         name: fileName,
//         data: chunkedStream,
//       );
//       print('Progress: 100%');
//     } catch (error) {
//       if (kDebugMode) {
//         print('Error uploading file: $error');
//       }
//     }
//   } else {
//     if (kDebugMode) {
//       print('File was not picked');
//     }
//   }
// }
