part of 'chat_bloc.dart';

enum SendDialogMessageStatus { initial, sent, error }

@immutable
class ChatState extends Equatable {
  final SendDialogMessageStatus sendDialogMessageStatus;

  const ChatState({required this.sendDialogMessageStatus});

  static ChatState initial() {
    return const ChatState(
      sendDialogMessageStatus: SendDialogMessageStatus.initial,
    );
  }

  @override
  List<Object?> get props => [sendDialogMessageStatus];

  ChatState copyWith({
    SendDialogMessageStatus? sendDialogMessageStatus,
  }) {
    return ChatState(
      sendDialogMessageStatus:
          sendDialogMessageStatus ?? this.sendDialogMessageStatus,
    );
  }
}
