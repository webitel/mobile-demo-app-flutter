import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  static const chatEvent = EventChannel("webitel.com/chat");

  @override
  void initState() {
    super.initState();
    _chatListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  sendText();
                },
                child: const Text("send text")
            ),
            ElevatedButton(
                onPressed: () {
                  getHistory();
                },
                child: const Text("get history")
            ),
            ElevatedButton(
                onPressed: () {
                  getUpdates();
                },
                child: const Text("get updates")
            ),
          ],
        ),
      ),
    );
  }

  void _chatListener() {
    chatEvent.receiveBroadcastStream().listen((event) {
      var messages = event['messages'] as List<dynamic>;

      /**
       * methods:
       *
       *  onReceive - received a new incoming message;
       *
       *  onSent - event received after message delivery;
       *
       *  getHistory - event received after a call to the getHistory method;
       *
       *  getUpdates - event received after a call to the getUpdates method;
       */
      var method = event['method'];
      print('method - $method');

      if(messages.isNotEmpty) {
        print('messageId - ${messages.first['id']}');
        print('text - ${messages.first['text']}');
        print('isIncoming - ${messages.first['isIncoming']}');
        print('sentAt - ${messages.first['sentAt']}');
        print('from - ${messages.first['from']}');
      }

      print('length - ${messages.length}');

      print(event);
    });
  }

  void sendText() {
    MyApp.channel
        .invokeMethod("sendText", <String, String>{'text': "Test text 1"});
  }

  CupertinoNavigationBar buildNavigationBar(BuildContext context) {
    return const CupertinoNavigationBar(backgroundColor: Colors.grey);
  }

  void getHistory() {
    /**
     * getHistory:
     *  method returns the history of the dialog.
     *
     *  optional parameters:
     *    - limit - the number of messages. Default is 50.
     *    - offset - the oldest messageId received.
     *      Use this option if you need to get older history.
     */
    MyApp.channel.invokeMethod("getHistory", <String, String>{});
  }

  void getUpdates() {
    /**
     * getUpdates:
     *  method returns messages that have not yet been received.
     *
     *  optional parameters:
     *    - limit - the number of messages. Default is 50.
     *    - offset - the last messageId received.
     */
    MyApp.channel.invokeMethod("getUpdates", <String, String>{});
  }
}
