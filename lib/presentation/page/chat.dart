import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webitel_sdk/backbone/dependency_injection.dart' as di;
import 'package:webitel_sdk/domain/entity/dialog_message.dart';
import 'package:webitel_sdk/presentation/bloc/chat_bloc.dart';
import 'package:webitel_sdk/presentation/widget/message_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc chatBloc;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String messageContent = '';

  @override
  void initState() {
    chatBloc = di.locator.get<ChatBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: ListView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.83,
                  child: Scrollbar(
                    controller: _scrollController,
                    trackVisibility: true,
                    thickness: 2,
                    thumbVisibility: true,
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (BuildContext context, message) {
                        return const MessageItem();
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Divider(thickness: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 127),
                              child: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _textEditingController,
                                onChanged: (value) {
                                  messageContent = value;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Type here',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              chatBloc.add(
                                SendDialogMessageEvent(
                                  dialogMessageEntity: DialogMessageEntity(
                                    dialogMessageContent: messageContent,
                                    peer: Peer(
                                      id: '',
                                      type: 'chat',
                                      name: '',
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: SvgPicture.asset(
                                'assets/icons/send_message.svg',
                                colorFilter: const ColorFilter.mode(
                                    Colors.green, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
