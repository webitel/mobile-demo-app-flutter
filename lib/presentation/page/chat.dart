import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uuid/uuid.dart';
import 'package:webitel_sdk/backbone/dependency_injection.dart' as di;
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/presentation/bloc/auth/auth_bloc.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/widget/messages_listview.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc chatBloc;
  late AuthBloc authBloc;

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String messageContent = '';

  @override
  void initState() {
    chatBloc = di.locator.get<ChatBloc>();
    authBloc = di.locator.get<AuthBloc>();
    authBloc.add(InitClientEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: BlocListener<AuthBloc, AuthState>(
              bloc: authBloc,
              listener: (context, state) {
                if (state.authStatus == AuthStatus.success) {
                  chatBloc.add(FetchDialogs(client: state.client!));
                } else if (state.authStatus == AuthStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.error.toString(),
                      ),
                    ),
                  );
                  chatBloc.add(FetchMessages());
                }
              },
              child: ListView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.83,
                    child: Scrollbar(
                      controller: _scrollController,
                      trackVisibility: true,
                      thickness: 2,
                      thumbVisibility: true,
                      child: MessagesListView(
                        chatBloc: chatBloc,
                        authBloc: authBloc,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Divider(thickness: 2),
                      BlocBuilder<ChatBloc, ChatState>(
                        bloc: chatBloc,
                        builder: (context, state) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 127),
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
                                    const uuid = Uuid();
                                    _textEditingController.clear();
                                    chatBloc.add(
                                      SendDialogMessageEvent(
                                        dialogMessageEntity:
                                            DialogMessageEntity(
                                          id: 0,
                                          dialogMessageContent: messageContent,
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
                                        Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    chatBloc.add(UploadMediaEvent());
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Image.asset(
                                      'assets/images/add_file.png',
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                                if (state.selectedFile.path.isNotEmpty) ...[
                                  Image.file(
                                    state.selectedFile,
                                    width: 50,
                                    height: 50,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      chatBloc.add(ClearImageFromStateEvent());
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
