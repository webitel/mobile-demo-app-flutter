part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState extends Equatable {
  final AuthStatus authStatus;

  const AuthState({required this.authStatus});

  static AuthState initial() {
    return const AuthState(
      authStatus: AuthStatus.initial,
    );
  }

  @override
  List<Object?> get props => [authStatus];

  AuthState copyWith({
    AuthStatus? authStatus,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
    );
  }
}
