import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webitel_sdk/backbone/dependency_injection.dart' as di;
import 'package:webitel_sdk/presentation/bloc/auth/auth_bloc.dart';
import 'package:webitel_sdk/presentation/bloc/chat/chat_bloc.dart';
import 'package:webitel_sdk/presentation/widget/chat_body.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatBloc chatBloc;
  late AuthBloc authBloc;

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
                final chatBloc = di.locator.get<ChatBloc>();
                if (state.authStatus == AuthStatus.success &&
                    state.client != null) {
                  chatBloc.add(FetchDialogs(client: state.client!));
                } else if (state.authStatus == AuthStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error.toString())),
                  );
                  chatBloc.add(FetchMessages());
                }
              },
              child: ChatBody(
                chatBloc: chatBloc,
                authBloc: authBloc,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
