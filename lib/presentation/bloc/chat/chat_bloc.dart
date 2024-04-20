import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webitel_sdk/backbone/message_type_helper.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/domain/usecase/database/clear_usecase.dart';
import 'package:webitel_sdk/domain/usecase/database/fetch_messages_by_chat_id.dart';
import 'package:webitel_sdk/domain/usecase/database/write_messages_to_database_usecase.dart';
import 'package:webitel_sdk/domain/usecase/send_dialog_message_usecase.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ClearDatabaseUseCase _clearDatabaseUseCase;
  final FetchMessagesByChatIdUseCase _fetchMessagesByChatIdUseCase;
  final WriteMessagesToDatabaseUseCase _writeMessagesToDatabaseUseCase;
  final SendDialogMessageUseCase _sendDialogMessageUseCase;

  ChatBloc(
    this._clearDatabaseUseCase,
    this._sendDialogMessageUseCase,
    this._writeMessagesToDatabaseUseCase,
    this._fetchMessagesByChatIdUseCase,
  ) : super(ChatState.initial()) {
    on<FetchUpdatesEvent>(
      (event, emit) async {
        await _writeMessagesToDatabaseUseCase(); // To write updates to DB
        final messages =
            await _fetchMessagesByChatIdUseCase(); // Fetch newest 20 messages from DB
        emit(state.copyWith(dialogMessages: messages));
      },
    );
    on<ListenIncomingOperatorMessagesEvent>(
      (event, emit) async {
        final messagesStreamController =
            await WebitelSdkPackage.instance.eventHandler.listenToMessages();

        await emit.onEach(messagesStreamController.stream, onData: (message) {
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
          emit(state.copyWith(dialogMessages: currentMessages));
        });
      },
    );
    on<ListenConnectStatusEvent>((event, emit) async {
      final connectStatusStreamController =
          await WebitelSdkPackage.instance.eventHandler.listenConnectStatus();
      await WebitelSdkPackage.instance.chatListHandler.fetchDialogs();
      await emit.onEach(connectStatusStreamController.stream, onData: (status) {
        if (kDebugMode) {
          print(status.status.name);
          print(status.errorMessage);
        }
      });
    });

    on<LoginToChannelEvent>(
      (event, emit) async {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

          final res = await WebitelSdkPackage.instance.authHandler.login(
            appToken:
                '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
            baseUrl: event.baseUrl,
            clientToken: event.clientToken,
            deviceId: event.deviceId,
            appName: packageInfo.appName,
            appVersion: packageInfo.version,
            osName: 'Android',
            osVersion: androidInfo.version.release,
            deviceModel: androidInfo.model,
          );
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          final res = await WebitelSdkPackage.instance.authHandler.login(
            appToken:
                '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
            baseUrl: event.baseUrl,
            clientToken: event.clientToken,
            deviceId: event.deviceId,
            appName: packageInfo.appName,
            appVersion: packageInfo.version,
            osName: iosInfo.systemName,
            osVersion: iosInfo.systemVersion,
            deviceModel: iosInfo.model,
          );

          if (res.status.name == 'success') {
            add(ListenIncomingOperatorMessagesEvent());
            add(ListenConnectStatusEvent());
            add(FetchUpdatesEvent());
          }
        }
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
