import 'package:grpc/grpc.dart';
import 'package:webitel_sdk_package/src/generated/portal/customer.pbgrpc.dart';

class GrpcGateway {
  String baseUrl = "dev.webitel.com";

  GrpcGateway._internal();
  static final GrpcGateway _instance = GrpcGateway._internal();

  factory GrpcGateway() => _instance;

  static GrpcGateway get instance => _instance;

  late CustomerClient _customerClient;

  Future<void> init() async {
    _createChannel();
  }
  CustomerClient get customerClient {
    return _customerClient;
  }
  _createChannel() {
    final channel = ClientChannel(
      baseUrl,
      port: 443,
      options: const ChannelOptions(),
    );
    _customerClient = CustomerClient(channel);
  }
}
