import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/dialog_message_entity.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';

import '../../domain/entity/msg_type.dart';

class MessageItem extends StatelessWidget {
  final String content;
  final MsgType messageType;
  final String filePath;
  final Keyboard? keyboard;
  final int mid;
  final ChatBloc chatBloc;

  const MessageItem({
    required this.mid,
    required this.chatBloc,
    required this.messageType,
    required this.content,
    required this.filePath,
    this.keyboard,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(filePath.isNotEmpty ? 8 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(20),
          topLeft: Radius.circular(messageType == MsgType.user ? 20 : 0),
          bottomLeft: const Radius.circular(20),
          bottomRight:
              Radius.circular(messageType == MsgType.operator ? 20 : 0),
        ),
        color: messageType == MsgType.user
            ? Colors.yellow.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (filePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(filePath),
                ),
              ),
            if (filePath.isNotEmpty && content.isNotEmpty)
              const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontFamily: 'Bebas',
              ),
            ),
            if (keyboard != null)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children: keyboard!.buttons.expand((buttonList) {
                  return buttonList.map((button) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      child: ElevatedButton(
                        onPressed: () {
                          chatBloc.add(
                            SendPostbackEvent(
                              postback: Postback(
                                code: button.code ?? '',
                                text: button.text,
                                mid: mid,
                              ),
                            ),
                          );
                        },
                        child: Text(button.text),
                      ),
                    );
                  }).toList();
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
