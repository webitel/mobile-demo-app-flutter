import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:webitel_portal_sdk/webitel_portal_sdk.dart';
import 'package:webitel_sdk/domain/entity/response_entity.dart';
import 'package:webitel_sdk/domain/service/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthService authService;

  AuthBloc(this.authService) : super(AuthState.initial()) {
    on<RegisterDevice>(
      (event, emit) async {
        if (state.client != null) {
          await authService.registerDevice(client: state.client!);
        }
      },
    );
    on<LogoutEvent>(
      (event, emit) async {
        if (state.client != null) {
          await authService.logout(client: state.client!);
        }
      },
    );
    on<InitClientEvent>(
      (event, emit) async {
        final client = await authService.initClient();
        add(LoginEvent());
        emit(
          state.copyWith(client: client),
        );
      },
    );
    on<LoginEvent>(
      (event, emit) async {
        emit(
          state.copyWith(
            authStatus: AuthStatus.loading,
          ),
        );
        if (state.client != null) {
          final res = await authService.login(client: state.client!);
          if (res.status == ResponseStatus.success) {
            emit(
              state.copyWith(
                authStatus: AuthStatus.success,
              ),
            );
          } else {
            emit(
              state.copyWith(
                authStatus: AuthStatus.error,
              ),
            );
          }
        }
      },
    );
  }
}
