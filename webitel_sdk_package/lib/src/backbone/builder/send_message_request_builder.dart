import 'package:webitel_sdk_package/src/generated/chat/messages/peer.pb.dart';
import 'package:webitel_sdk_package/src/generated/portal/messages.pb.dart';

class SendMessageRequestBuilder {
  late String text;
  late Peer peer;

  SendMessageRequestBuilder setText(String text) {
    this.text = text;
    return this;
  }

  SendMessageRequestBuilder setPeer(Peer peer) {
    this.peer = peer;
    return this;
  }

  SendMessageRequest build() {
    return SendMessageRequest(
      text: text,
      peer: peer,
    );
  }
}
