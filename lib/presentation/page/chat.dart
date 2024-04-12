import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webitel_sdk/backbone/dependency_injection.dart' as di;
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/device_info/device_info_bloc.dart';
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
  late ChatBloc chatBloc;
  late DeviceInfoBloc deviceInfoBloc;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final StreamController<DialogMessageEntity> streamController;
  String messageContent = '';

  @override
  void initState() {
    chatBloc = di.locator.get<ChatBloc>();
    deviceInfoBloc = di.locator.get<DeviceInfoBloc>();
    deviceInfoBloc.add(FetchDeviceIdEvent());
    initClient(
      deviceId: '8b98475e-21f9-47bf-b10a-125a83731a33',
      clientToken:
          '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
      baseUrl: 'dev.webitel.com',
    );
    chatBloc.add(ListenIncomingOperatorMessages());
    super.initState();
  }

  Future<void> initClient({
    String? deviceId,
    required String baseUrl,
    required String clientToken,
  }) async {
    await WebitelSdkPackage.instance.clientInitializer.initializeClient(
      baseUrl: baseUrl,
      clientToken: clientToken,
      deviceId: deviceId,
    );
    await WebitelSdkPackage.instance.authHandler.login();
    await WebitelSdkPackage.instance.grpcStreamInitializer
        .connectToGrpcChannel();
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
                    child: BlocBuilder<ChatBloc, ChatState>(
                      bloc: chatBloc,
                      builder: (context, state) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: state.dialogMessages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return MessageItem(
                              content: state
                                  .dialogMessages[index].dialogMessageContent,
                            );
                          },
                        );
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
                              _textEditingController.clear();
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
