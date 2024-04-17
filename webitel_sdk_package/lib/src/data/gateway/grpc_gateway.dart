import 'package:grpc/grpc.dart';
import 'package:webitel_sdk_package/src/backbone/builder/call_options_builder.dart';
import 'package:webitel_sdk_package/src/backbone/builder/user_agent_builder.dart';
import 'package:webitel_sdk_package/src/data/interceptor/interceptor.dart';
import 'package:webitel_sdk_package/src/generated/portal/customer.pbgrpc.dart';

class GrpcGateway {
  late CustomerClient _stub;
  late String _accessToken = '';
  late String _baseUrl;
  late String _deviceId;
  late String _clientToken;
  late String _userAgent;

  Future<void> init({
    required String baseUrl,
    required String clientToken,
    required String deviceId,
    required UserAgentBuilder userAgentBuilder,
  }) async {
    _baseUrl = baseUrl;
    _deviceId = deviceId;
    _clientToken = clientToken;
    _userAgent = userAgentBuilder.build();
    _createChannel(
      baseUrl: baseUrl,
      deviceId: deviceId,
      clientToken: clientToken,
      userAgent: _userAgent,
    );
  }

  Future<void> setAccessToken(String accessToken) async {
    _accessToken = accessToken;

    _createChannel(
      baseUrl: _baseUrl,
      deviceId: _deviceId,
      clientToken: _clientToken,
      userAgent: _userAgent,
    );
  }

  CustomerClient get stub {
    return _stub;
  }

  _createChannel({
    required String baseUrl,
    required String deviceId,
    required String clientToken,
    required String userAgent,
  }) {
    final channel = ClientChannel(
      baseUrl,
      port: 443,
      options: ChannelOptions(userAgent: userAgent),
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
