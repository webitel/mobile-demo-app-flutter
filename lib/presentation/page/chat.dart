import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webitel_sdk/presentation/widget/message_item.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textEditingController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

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
                                onChanged: (value) {},
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
                              WebitelSdkPackage()
                                  .pingServer(echo: [1, 2, 3, 4]);
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
