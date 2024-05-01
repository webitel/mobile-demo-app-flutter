part of 'chat_bloc.dart';

sealed class ChatEvent {}

class SendDialogMessageEvent extends ChatEvent {
  final DialogMessageEntity dialogMessageEntity;

  SendDialogMessageEvent({required this.dialogMessageEntity});
}

class ListenToMessages extends ChatEvent {}

class FetchMessages extends ChatEvent {}

class UploadMediaEvent extends ChatEvent {}

class ClearImageFromStateEvent extends ChatEvent {}
