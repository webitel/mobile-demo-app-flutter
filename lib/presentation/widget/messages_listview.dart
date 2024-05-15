import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/presentation/bloc/auth/auth_bloc.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/widget/message_item.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({
    super.key,
    required this.chatBloc,
    required this.authBloc,
  });

  final ChatBloc chatBloc;
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: chatBloc,
      builder: (context, state) {
        return InfiniteList(
          onFetchData: () {
            if (authBloc.state.client != null) {
              chatBloc.add(
                FetchPaginationMessages(),
              );
            }
          },
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
                filePath: state.dialogMessages[index].file != null
                    ? state.dialogMessages[index].file!.path!
                    : '',
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
