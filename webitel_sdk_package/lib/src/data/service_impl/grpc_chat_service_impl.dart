import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk_package/src/data/gateway/grpc_gateway.dart';
import 'package:webitel_sdk_package/src/data/gateway/shared_preferences_gateway.dart';
import 'package:webitel_sdk_package/src/domain/entities/dialog_message.dart';
import 'package:webitel_sdk_package/src/domain/services/grpc_chat/grpc_chat_service.dart';
import 'package:webitel_sdk_package/src/exceptions/grpc_exception.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/history.pb.dart';
import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/google/protobuf/any.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/connect.pb.dart'
    as portal;
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class GrpcChatServiceImpl implements GrpcChatService {
  final GrpcGateway _grpcGateway;
  final SharedPreferencesGateway _sharedPreferencesGateway;

  late final StreamController<portal.Request> _requestStreamController;
  late final StreamController<portal.Response> _responseStreamController;
  late final StreamController<UpdateNewMessage> _updateStreamController;
  late final StreamController<DialogMessageEntity> _userMessagesController;

  final uuid = Uuid();
  bool? connectClosed;

  GrpcChatServiceImpl(
    this._sharedPreferencesGateway,
    this._grpcGateway,
  ) {
    _requestStreamController = StreamController<portal.Request>.broadcast();
    _responseStreamController = StreamController<portal.Response>.broadcast();
    _updateStreamController = StreamController<UpdateNewMessage>.broadcast();
    _userMessagesController = StreamController<DialogMessageEntity>.broadcast();
  }

  @override
  Future<ConnectStatus> listenConnectStatus() async {
    if (connectClosed != null) {
      if (connectClosed == true) {
        return ConnectStatus.closed;
      } else if (connectClosed == false) {
        return ConnectStatus.opened;
      }
    }
    return ConnectStatus.closed;
  }

  @override
  Future<void> connectToGrpcChannel() async {
    _grpcGateway.stub.connect(_requestStreamController.stream).listen(
      (update) {
        connectClosed = false;
        final canUnpackIntoResponse =
            update.data.canUnpackInto(portal.Response());
        final canUnpackIntoUpdateNewMessage =
            update.data.canUnpackInto(UpdateNewMessage());
        if (canUnpackIntoResponse == true) {
          final decodedResponse = update.data.unpackInto(portal.Response());
          _responseStreamController.add(decodedResponse);
        } else if (canUnpackIntoUpdateNewMessage == true) {
          final decodedResponse = update.data.unpackInto(UpdateNewMessage());
          _updateStreamController.add(decodedResponse);
        }
      },
      onError: (error) {
        connectClosed = true;
        _responseStreamController.addError(
            GrpcException(message: error.toString(), thrownException: error));
        _updateStreamController.addError(
            GrpcException(message: error.toString(), thrownException: error));
      },
      onDone: () {
        _responseStreamController
            .addError(GrpcException(message: 'Connect was closed'));
        _updateStreamController
            .addError(GrpcException(message: 'Connect was closed'));
        connectClosed = true;
      },
      cancelOnError: true,
    );
  }

  @override
  Future<Stream<DialogMessageEntity>> listenToOperatorMessages(
      {required String id}) async {
    _updateStreamController.stream.listen((update) {
      _userMessagesController.add(
        DialogMessageEntity(
          dialogMessageContent: update.message.text,
          peer: PeerInfo(
            id: update.message.chat.peer.id,
            name: update.message.chat.peer.name,
            type: update.message.chat.peer.type,
          ),
        ),
      );
    });
    return _userMessagesController.stream;
  }

  @override
  Future<DialogMessageEntity> sendDialogMessage(
      {required DialogMessageEntity message}) async {
    final completer = Completer<DialogMessageEntity>();
    final maxRetries = 5;
    var attempt = 0;
    var consecutiveErrors = 0;
    final id = uuid.v4();

    while (!completer.isCompleted && attempt < maxRetries) {
      try {
        final newMessageRequest = SendMessageRequest(
          text: message.dialogMessageContent,
          peer: Peer(
            id: message.peer.id,
            type: message.peer.type,
            name: message.peer.name,
          ),
        );

        final request = portal.Request(
          path: '/webitel.portal.ChatMessages/SendMessage',
          data: Any.pack(newMessageRequest),
          id: id,
        );
        if (connectClosed == true) {
          await connectToGrpcChannel();
        }
        _requestStreamController.add(request);

        StreamSubscription<portal.Response>? subscription;
        subscription = _responseStreamController.stream.listen((response) {
          if (response.id == id) {
            final canUnpackIntoUpdateNewMessage =
                response.data.canUnpackInto(UpdateNewMessage());
            if (canUnpackIntoUpdateNewMessage == true) {
              final unpackedMessage =
                  response.data.unpackInto(UpdateNewMessage());
              _sharedPreferencesGateway.clearPreferences();
              if (!completer.isCompleted) {
                completer.complete(
                  DialogMessageEntity(
                    dialogMessageContent: unpackedMessage.message.text,
                    peer: PeerInfo(
                      name: unpackedMessage.message.chat.peer.name,
                      type: unpackedMessage.message.chat.peer.type,
                      id: unpackedMessage.message.chat.peer.id,
                    ),
                  ),
                );
              }

              print('completed');
              subscription?.cancel();
            }
          }
        }, onError: (error) {
          if (error is GrpcError) {
            print(error);
            subscription?.cancel();
            consecutiveErrors++;
            if (consecutiveErrors == maxRetries) {
              completer.complete(
                DialogMessageEntity(
                  dialogMessageContent: error.toString(),
                  peer: PeerInfo(
                    name: 'ERROR',
                    type: 'Unknown',
                    id: '',
                  ),
                ),
              );
            }
          }
        }, onDone: () {});
        await completer.future.timeout(Duration(seconds: 2));
        if (completer.isCompleted) {
          consecutiveErrors = 0;
          attempt = 0;
          return completer.future;
        }
      } catch (error) {
        print(error);
      }
      attempt++;
    }
    return DialogMessageEntity(
      dialogMessageContent: 'Unknown Error',
      peer: PeerInfo(
        name: 'ERROR',
        type: 'Unknown',
        id: '',
      ),
    );
  }

  @override
  Future<List<DialogMessageEntity>> fetchDialogs() async {
    final maxRetries = 5;
    var attempt = 0;
    var consecutiveErrors = 0;
    final completer = Completer<List<DialogMessageEntity>>();
    final messages = [];

    while (!completer.isCompleted && attempt < maxRetries) {
      try {
        final id = uuid.v4();

        final fetchDialogsRequest = ChatMessagesRequest(chatId: '');
        final request = portal.Request(
          path: '/webitel.portal.ChatMessages/ChatHistory',
          data: Any.pack(fetchDialogsRequest),
          id: id,
        );
        if (connectClosed == true) {
          await connectToGrpcChannel();
        }
        _requestStreamController.add(request);

        StreamSubscription<portal.Response>? subscription;
        subscription = _responseStreamController.stream.listen((response) {
          if (response.id == id) {
            final canUnpackIntoDialogMessages =
                response.data.canUnpackInto(ChatMessages());
            if (canUnpackIntoDialogMessages == true) {
              final unpackedDialogMessages =
                  response.data.unpackInto(ChatMessages());

              for (var unpackedMessage in unpackedDialogMessages.messages) {
                messages.add(
                  DialogMessageEntity(
                    dialogMessageContent: unpackedMessage.text,
                    peer: PeerInfo(
                      name: unpackedMessage.chat.peer.name,
                      type: unpackedMessage.chat.peer.type,
                      id: unpackedMessage.chat.peer.id,
                    ),
                  ),
                );
              }
              print('completed');
              subscription?.cancel();
            }
          }
        }, onError: (error) {
          if (error is GrpcError) {
            print(error);
            subscription?.cancel();
            consecutiveErrors++;
            if (consecutiveErrors == maxRetries) {
              return [];
            }
          }
        }, onDone: () {});
        await completer.future.timeout(Duration(seconds: 1));
        if (completer.isCompleted) {
          consecutiveErrors = 0;
          attempt = 0;
          return completer.future;
        }
      } catch (error) {
        print(error);
      }
      attempt++;
    }
    return [];
  }

  @override
  Future<List<DialogMessageEntity>> fetchUpdates() async {
    final maxRetries = 5;
    var attempt = 0;
    var consecutiveErrors = 0;
    final completer = Completer<List<DialogMessageEntity>>();
    final messages = [];

    while (!completer.isCompleted && attempt < maxRetries) {
      try {
        final id = uuid.v4();

        final fetchUpdatesRequest = ChatMessagesRequest(chatId: '');
        final request = portal.Request(
          path: '/webitel.portal.ChatMessages/ChatUpdates',
          data: Any.pack(fetchUpdatesRequest),
          id: id,
        );
        if (connectClosed == true) {
          await connectToGrpcChannel();
        }
        _requestStreamController.add(request);

        StreamSubscription<portal.Response>? subscription;
        subscription = _responseStreamController.stream.listen((response) {
          if (response.id == id) {
            final canUnpackIntoDialogMessages =
                response.data.canUnpackInto(ChatMessages());
            if (canUnpackIntoDialogMessages == true) {
              final unpackedDialogMessages =
                  response.data.unpackInto(ChatMessages());

              for (var unpackedMessage in unpackedDialogMessages.messages) {
                messages.add(
                  DialogMessageEntity(
                    dialogMessageContent: unpackedMessage.text,
                    peer: PeerInfo(
                      name: unpackedMessage.chat.peer.name,
                      type: unpackedMessage.chat.peer.type,
                      id: unpackedMessage.chat.peer.id,
                    ),
                  ),
                );
              }
              print('completed');
              subscription?.cancel();
            }
          }
        }, onError: (error) {
          if (error is GrpcError) {
            print(error);
            subscription?.cancel();
            consecutiveErrors++;
            if (consecutiveErrors == maxRetries) {
              return [];
            }
          }
        }, onDone: () {});
        await completer.future.timeout(Duration(seconds: 1));
        if (completer.isCompleted) {
          consecutiveErrors = 0;
          attempt = 0;
          return completer.future;
        }
      } catch (error) {
        print(error);
      }
      attempt++;
    }
    return [];
  }

  void dispose() {
    _requestStreamController.close();
    _responseStreamController.close();
    _updateStreamController.close();
    _userMessagesController.close();
  }
}
