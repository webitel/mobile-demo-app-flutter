part of 'chat_bloc.dart';

enum AuthStatus { initial, error, authorized }

@immutable
class ChatState extends Equatable {
  final List<DialogMessageEntity> dialogMessages;
  final AuthStatus authStatus;

  const ChatState({
    required this.authStatus,
    required this.dialogMessages,
  });

  static ChatState initial() {
    return const ChatState(
      dialogMessages: [],
      authStatus: AuthStatus.initial,
    );
  }

  @override
  List<Object?> get props => [
        dialogMessages,
        authStatus,
      ];

  ChatState copyWith({
    List<DialogMessageEntity>? dialogMessages,
    AuthStatus? authStatus,
  }) {
    return ChatState(
      dialogMessages: dialogMessages ?? this.dialogMessages,
      authStatus: authStatus ?? this.authStatus,
    );
  }
}
