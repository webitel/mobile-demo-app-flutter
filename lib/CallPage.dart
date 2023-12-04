import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPage();
}


class _CallPage extends State<CallPage> {
  static const channel = MethodChannel("webitel.com/portal");
  static const eventChannel = EventChannel("webitel.com/calls");
  List<String> callState = [];
  bool isActiveCall = false;

  @override
  void initState() {
    super.initState();
    _callStateListener();
    getCallState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(callState.toString()),
          const SizedBox(height: 80),
          isActiveCall
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          toggleMuteCall();
                        },
                        child: const Text("Mute")),
                    ElevatedButton(
                        onPressed: () {
                          toggleLoudSpeaker();
                        },
                        child: const Text("Speaker")),
                    ElevatedButton(
                        onPressed: () {
                          toggleHoldCall();
                        },
                        child: const Text("Hold")),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       //sendDigit("4");
                    //     },
                    //     child: const Text("Dtmf")),
                  ],
                )
              : Container(),
          const SizedBox(height: 50),
          !isActiveCall
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    makeCall();
                  },
                  child: const Text("Make Call"))
              : Container(),
          isActiveCall
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    disconnectCall();
                  },
                  child: const Text("Disconnect"))
              : Container(),
        ],
      ),
    );
  }

  CupertinoNavigationBar buildNavigationBar(BuildContext context) {
    return const CupertinoNavigationBar(backgroundColor: Colors.grey);
  }

  void stateChanged(List<String> states) {
    setState(() {
      callState = states;
      setVisibility(states);
    });
  }

  void setVisibility(List<String> states) {
    isActiveCall = !(states.isEmpty || states.contains("DISCONNECTED"));
  }

  void makeCall() {
    channel.invokeMethod("makeCall", <String, String>{});
  }

  void disconnectCall() {
    channel.invokeMethod("disconnectCall", <String, String>{});
  }

  void toggleMuteCall() {
    channel.invokeMethod("toggleMuteCall", <String, String>{});
  }

  void toggleHoldCall() {
    channel.invokeMethod("toggleHoldCall", <String, String>{});
  }

  void toggleLoudSpeaker() {
    channel.invokeMethod("toggleLoudSpeaker", <String, String>{});
  }

  void sendDigit(String digit) {
    channel.invokeMethod("sendDtmf", <String, String>{'dtmf': digit});
  }

  void _callStateListener() {
    eventChannel.receiveBroadcastStream().listen((event) {
      List<String> states = event['callState'].cast<String>();
      stateChanged(states);
      print('result:$states');
      print(event);
    });
  }

  void getCallState() {
    channel.invokeMethod("getCallState", <String, String>{});
  }
}
