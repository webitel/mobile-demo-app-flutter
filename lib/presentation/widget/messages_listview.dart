import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/widget/message_item.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({
    super.key,
    required this.chatBloc,
  });

  final ChatBloc chatBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: chatBloc,
      builder: (context, state) {
        return ListView.builder(
          reverse: true,
          itemCount: state.dialogMessages.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: 8,
                left:
                    state.dialogMessages[index].messageType == MessageType.user
                        ? 200
                        : 20,
                right: state.dialogMessages[index].messageType ==
                        MessageType.operator
                    ? 200
                    : 20,
              ),
              child: MessageItem(
                messageType: state.dialogMessages[index].messageType!,
                content: state.dialogMessages[index].dialogMessageContent,
              ),
            );
          },
        );
      },
    );
  }
}
