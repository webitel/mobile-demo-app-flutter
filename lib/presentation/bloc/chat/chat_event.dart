part of 'chat_bloc.dart';

sealed class ChatEvent {}

class SendDialogMessageEvent extends ChatEvent {
  final DialogMessageEntity dialogMessageEntity;

  SendDialogMessageEvent({required this.dialogMessageEntity});
}

class FetchDialogs extends ChatEvent {
  final PortalClient client;

  FetchDialogs({required this.client});
}

class ListenToMessages extends ChatEvent {}

class FetchMessages extends ChatEvent {}

class FetchPaginationMessages extends ChatEvent {}

class UploadFileEvent extends ChatEvent {}

class UploadImageEvent extends ChatEvent {}

class ClearImageFromStateEvent extends ChatEvent {}

class ListenToErrorEvent extends ChatEvent {
  final PortalClient client;

  ListenToErrorEvent({required this.client});
}
