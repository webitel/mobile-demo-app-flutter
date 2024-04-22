import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:webitel_sdk_package/src/domain/entities/error.dart';
import 'package:webitel_sdk_package/src/domain/services/error_service.dart';

abstract interface class ListenToErrorUseCase {
  Stream<ErrorEntity> call();
}

@LazySingleton(as: ListenToErrorUseCase)
class ListenToErrorImplUseCase implements ListenToErrorUseCase {
  final ErrorService _errorService;

  ListenToErrorImplUseCase(this._errorService);

  @override
  Stream<ErrorEntity> call() => _errorService.listenToErrors();
}
