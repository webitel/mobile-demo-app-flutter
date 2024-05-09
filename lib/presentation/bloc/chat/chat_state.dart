part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<DialogMessageEntity> dialogMessages;
  final File selectedFile;
  final Dialog? dialog;

  const ChatState({
    required this.dialog,
    required this.selectedFile,
    required this.dialogMessages,
  });

  static ChatState initial() {
    return ChatState(
      dialog: null,
      selectedFile: File(''),
      dialogMessages: const [],
    );
  }

  @override
  List<Object?> get props => [
        dialogMessages,
        selectedFile,
        dialog,
      ];

  ChatState copyWith({
    List<DialogMessageEntity>? dialogMessages,
    File? selectedFile,
    Dialog? dialog,
  }) {
    return ChatState(
      dialogMessages: dialogMessages ?? this.dialogMessages,
      selectedFile: selectedFile ?? this.selectedFile,
      dialog: dialog ?? this.dialog,
    );
  }
}
