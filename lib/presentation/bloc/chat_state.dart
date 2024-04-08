part of 'chat_bloc.dart';

enum SendDialogMessageStatus { initial, sent, error }

@immutable
class ChatState extends Equatable {
  final SendDialogMessageStatus sendDialogMessageStatus;
  final List<DialogMessageEntity> dialogMessages;

  const ChatState({
    required this.sendDialogMessageStatus,
    required this.dialogMessages,
  });

  static ChatState initial() {
    return const ChatState(
      sendDialogMessageStatus: SendDialogMessageStatus.initial,
      dialogMessages: [],
    );
  }

  @override
  List<Object?> get props => [
        sendDialogMessageStatus,
        dialogMessages,
      ];

  ChatState copyWith({
    SendDialogMessageStatus? sendDialogMessageStatus,
    List<DialogMessageEntity>? dialogMessages,
  }) {
    return ChatState(
      sendDialogMessageStatus:
          sendDialogMessageStatus ?? this.sendDialogMessageStatus,
      dialogMessages: dialogMessages ?? this.dialogMessages,
    );
  }
}
