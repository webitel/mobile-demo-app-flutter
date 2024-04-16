import 'package:grpc/grpc.dart';
import 'package:webitel_sdk_package/src/builder/call_options_builder.dart';
import 'package:webitel_sdk_package/src/data/interceptor/interceptor.dart';
import 'package:webitel_sdk_package/src/generated/portal/customer.pbgrpc.dart';

class GrpcGateway {
  late CustomerClient _stub;
  late String _accessToken = '';
  late String _baseUrl;
  late String _deviceId;
  late String _clientToken;

  Future<void> init({
    required String baseUrl,
    required String clientToken,
    required String deviceId,
  }) async {
    _baseUrl = baseUrl;
    _deviceId = deviceId;
    _clientToken = clientToken;
    _createChannel(
      baseUrl: baseUrl,
      deviceId: deviceId,
      clientToken: clientToken,
    );
  }

  Future<void> setAccessToken(String accessToken) async {
    _accessToken = accessToken;

    _createChannel(
      baseUrl: _baseUrl,
      deviceId: _deviceId,
      clientToken: _clientToken,
    );
  }

  CustomerClient get stub {
    return _stub;
  }

  _createChannel({
    required String baseUrl,
    required String deviceId,
    required String clientToken,
  }) {
    final channel = ClientChannel(
      baseUrl,
      port: 443,
      options: const ChannelOptions(),
    );
    _stub = CustomerClient(
      interceptors: [GRPCInterceptor()],
      channel,
      options: CallOptionsBuilder()
          .setDeviceId(deviceId)
          .setClientToken(clientToken)
          .setAccessToken(_accessToken)
          .build(),
    );
  }
}
