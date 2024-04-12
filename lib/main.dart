import 'package:flutter/material.dart';
import 'package:webitel_sdk/backbone/dependency_injection.dart';

import 'presentation/page/chat.dart';

void main() async {
  runApp(const MyApp());
  await registerDi();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: const ChatPage(),
    );
  }
}
