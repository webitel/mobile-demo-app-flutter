part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<DialogMessageEntity> dialogMessages;

  const ChatState({
    required this.dialogMessages,
  });

  static ChatState initial() {
    return const ChatState(
      dialogMessages: [],
    );
  }

  @override
  List<Object?> get props => [
        dialogMessages,
      ];

  ChatState copyWith({
    List<DialogMessageEntity>? dialogMessages,
  }) {
    return ChatState(
      dialogMessages: dialogMessages ?? this.dialogMessages,
    );
  }
}
