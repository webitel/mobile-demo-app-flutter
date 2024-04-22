import 'package:webitel_sdk_package/src/domain/entities/error.dart';

abstract interface class ErrorService {
  Stream<ErrorEntity> listenToErrors();
}
