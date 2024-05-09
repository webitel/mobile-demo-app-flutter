import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthService authService;

  AuthBloc(this.authService) : super(AuthState.initial()) {
    on<LoginEvent>((event, emit) async {
      emit(state.copyWith(authStatus: AuthStatus.loading));
      final res = await authService.login(
        appToken:
            '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
        clientToken:
            '49sFBWUGEtlHz7iTWjIXIgRGnZXQ4dQZOy7fdM8AyffZ3oEQzNC5Noa6Aeem6BAw',
        baseUrl: 'dev.webitel.com',
      );
      if (res.status == ResponseStatus.success) {
        emit(state.copyWith(authStatus: AuthStatus.success));
      } else {
        emit(
          state.copyWith(
            authStatus: AuthStatus.error,
            error: res.message,
          ),
        );
      }
    });
  }
}
