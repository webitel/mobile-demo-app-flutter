import 'package:webitel_sdk/domain/entity/response_entity.dart';

abstract interface class AuthService {
  Future<ResponseEntity> login({
    required String appToken,
    required String baseUrl,
    required String clientToken,
  });
}