import 'package:grpc/grpc.dart';
import 'package:webitel_sdk_package/src/generated/portal/customer.pbgrpc.dart';

class GrpcGateway {
  late CustomerClient _customerClient;
  late String _accessToken = '';
  late String _baseUrl;
  late String _deviceId;
  late String _clientToken;

  CallOptions createCallOptions({
    required String? deviceId,
    required String clientToken,
    required String accessToken,
  }) {
    return CallOptions(
      metadata: {
        'x-portal-device': deviceId ?? '',
        'x-portal-client': clientToken,
        'x-portal-access': accessToken,
      },
    );
  }

  Future<void> init({
    required String baseUrl,
    required String clientToken,
    String? deviceId,
  }) async {
    _baseUrl = baseUrl;
    _deviceId = deviceId ?? '';
    _clientToken = clientToken;
    _createChannel(
      baseUrl: baseUrl,
      deviceId: deviceId ?? '', //TODO if empty device id - generate it
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

  CustomerClient get customerClient {
    return _customerClient;
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
    _customerClient = CustomerClient(
      channel,
      options: createCallOptions(
        deviceId: deviceId,
        clientToken: clientToken,
        accessToken: _accessToken,
      ),
    );
  }
}
