part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<DialogMessageEntity> dialogMessages;
  final File selectedFile;

  const ChatState({
    required this.selectedFile,
    required this.dialogMessages,
  });

  static ChatState initial() {
    return ChatState(
      selectedFile: File(''),
      dialogMessages: const [],
    );
  }

  @override
  List<Object?> get props => [
        dialogMessages,
        selectedFile,
      ];

  ChatState copyWith({
    List<DialogMessageEntity>? dialogMessages,
    File? selectedFile,
  }) {
    return ChatState(
      dialogMessages: dialogMessages ?? this.dialogMessages,
      selectedFile: selectedFile ?? this.selectedFile,
    );
  }
}
