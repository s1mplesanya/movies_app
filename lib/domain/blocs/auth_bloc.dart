import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lesson3/domain/api_client/account_api_client.dart';
import 'package:lesson3/domain/api_client/auth_api_client.dart';
import 'package:lesson3/domain/data_providers/session_data_provider.dart';

abstract class AuthEvent {}

class AuthCheckEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String login;
  final String password;

  AuthLoginEvent({
    required this.login,
    required this.password,
  });
}

abstract class AuthState {}

class AuthAuthorizedState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthorizedState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthFailureState extends AuthState {
  final Object error;

  AuthFailureState(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailureState &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class AuthInProgressState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthorizedState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthCheckInProgressState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthorizedState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthUnauthorizedState extends AuthState {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthorizedState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _authApiClient = AuthApiClient();
  final _accountApiClient = AccountApiClient();
  final _sessionDataProvider = SessionDataProvider();

  AuthBloc(super.initialState) {
    on<AuthEvent>(
      (event, emit) async {
        if (event is AuthCheckEvent) {
          await onAuthCheckStatusEvent(event, emit);
        } else if (event is AuthLogoutEvent) {
          await onAuthLogoutEvent(event, emit);
        } else if (event is AuthLoginEvent) {
          await onAuthLoginEvent(event, emit);
        }
      },
      transformer: sequential(),
    );

    add(AuthCheckEvent());
  }

  Future<void> onAuthCheckStatusEvent(
    AuthCheckEvent event,
    Emitter<AuthState> emitter,
  ) async {
    emit(AuthInProgressState());
    final sessionId = await _sessionDataProvider.getSessionId();
    final newState =
        sessionId != null ? AuthAuthorizedState() : AuthUnauthorizedState();
    emit(newState);
  }

  Future<void> onAuthLoginEvent(
    AuthLoginEvent event,
    Emitter<AuthState> emitter,
  ) async {
    try {
      emit(AuthInProgressState());
      final sessionId = await _authApiClient.auth(
        username: event.login,
        password: event.password,
      );
      final accountId = await _accountApiClient.getAccountInfo(sessionId);

      await _sessionDataProvider.setSessionId(sessionId);
      await _sessionDataProvider.setAccountId(accountId);
      emit(AuthAuthorizedState());
    } catch (e) {
      emit(AuthFailureState(e));
    }
  }

  Future<void> onAuthLogoutEvent(
    AuthLogoutEvent event,
    Emitter<AuthState> emitter,
  ) async {
    try {
      await _sessionDataProvider.deleteSessionId();
      await _sessionDataProvider.deleteAccountId();
      emit(AuthUnauthorizedState());
    } catch (e) {
      emit(AuthFailureState(e));
    }
  }
}
