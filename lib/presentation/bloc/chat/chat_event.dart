part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class SendDialogMessageEvent extends ChatEvent {
  final DialogMessageEntity dialogMessageEntity;

  SendDialogMessageEvent({required this.dialogMessageEntity});
}

class ListenIncomingOperatorMessagesEvent extends ChatEvent {}

class ListenConnectStatusEvent extends ChatEvent {}

class FetchUpdatesEvent extends ChatEvent {}

class LoginToChannelEvent extends ChatEvent {
  final String baseUrl;
  final String clientToken;
  final String deviceId;

  LoginToChannelEvent(
      {required this.baseUrl,
      required this.clientToken,
      required this.deviceId});
}
