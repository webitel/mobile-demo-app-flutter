import 'package:flutter/material.dart';
import 'package:webitel_sdk_package/webitel_sdk_package.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String initialMessage = 'Test';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                WebitelSdkPackage().pingServer(echo: [1, 2, 3, 4]);
              },
              child: const Text('Ping'),
            ),
          ],
        ),
      ),
    );
  }
}
