import 'package:grpc/grpc.dart';

class HeaderBuilder {
  static CallOptions createCallOptions({
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
}
