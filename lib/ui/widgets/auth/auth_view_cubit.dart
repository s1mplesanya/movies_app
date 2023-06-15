import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:lesson3/domain/api_client/api_client_exteption.dart';
import 'package:lesson3/domain/blocs/auth_bloc.dart';

abstract class AuthViewCubicState {}

class AuthViewCubicFormFillInProgressState extends AuthViewCubicState {
  @override
  bool operator ==(covariant AuthViewCubicErrorState other) {
    if (identical(this, other)) return true;

    return other is AuthViewCubicAuthProgressState &&
        runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => 0;
}

class AuthViewCubicErrorState extends AuthViewCubicState {
  final String errorMessage;
  AuthViewCubicErrorState({
    required this.errorMessage,
  });

  @override
  bool operator ==(covariant AuthViewCubicErrorState other) {
    if (identical(this, other)) return true;

    return other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => errorMessage.hashCode;
}

class AuthViewCubicAuthProgressState extends AuthViewCubicState {
  @override
  bool operator ==(covariant AuthViewCubicErrorState other) {
    if (identical(this, other)) return true;

    return other is AuthViewCubicAuthProgressState &&
        runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => 0;
}

class AuthViewCubicSuccessState extends AuthViewCubicState {
  @override
  bool operator ==(covariant AuthViewCubicErrorState other) {
    if (identical(this, other)) return true;

    return other is AuthViewCubicAuthProgressState &&
        runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => 0;
}

class AuthViewCubic extends Cubit<AuthViewCubicState> {
  final AuthBloc authBloc;

  late final StreamSubscription<AuthState> authBlocSubscription;

  AuthViewCubic(
    super.initialState, {
    required this.authBloc,
  }) {
    _onState(authBloc.state);
    authBlocSubscription = authBloc.stream.listen(_onState);
  }

  void _onState(AuthState authState) {
    if (authState is AuthAuthorizedState) {
      authBlocSubscription.cancel();
      emit(AuthViewCubicSuccessState());
    } else if (authState is AuthUnauthorizedState) {
      emit(AuthViewCubicFormFillInProgressState());
    } else if (authState is AuthFailureState) {
      final message = _mapErrorToMessage(authState.error);
      emit(AuthViewCubicErrorState(errorMessage: message));
    } else if (authState is AuthInProgressState) {
      emit(AuthViewCubicAuthProgressState());
    } else if (authState is AuthCheckInProgressState) {
      emit(AuthViewCubicAuthProgressState());
    }
  }

  String _mapErrorToMessage(Object object) {
    if (object is! ApiClientException) {
      return 'Неизвестная ошибка, повторите попытку!';
    } else {
      switch (object.type) {
        case ApiClientExceptionType.network:
          return 'Сервер не доступен, проверьте подключение к интернету!';
        case ApiClientExceptionType.auth:
          return 'Неверный логин или пароль!';
        case ApiClientExceptionType.other:
          return 'Произошла ошибка, попробуйте ещё!';
        case ApiClientExceptionType.sessionExpired:
          return 'Произошла ошибка, попробуйте ещё!';
      }
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }

  bool _isValidLoginAndPassword(String login, String password) =>
      login.isNotEmpty && password.isNotEmpty;

  Future<void> auth(
    BuildContext context, {
    required String login,
    required String password,
  }) async {
    if (!_isValidLoginAndPassword(login, password)) {
      emit(AuthViewCubicErrorState(errorMessage: 'Заполните логин и пароль!'));
      return;
    }
    authBloc.add(AuthLoginEvent(login: login, password: password));
  }
}

// class AuthViewModel extends ChangeNotifier {
  // final loginTextController = TextEditingController();
  // final passwordTextController = TextEditingController();

//   final _authService = AuthService();

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   bool _isAuthProgress = false;
//   bool get canStartAuth => !_isAuthProgress;
//   bool get isAuthProgress => _isAuthProgress;

//   bool _isValidLoginAndPassword(String login, String password) =>
//       login.isNotEmpty && password.isNotEmpty;

//   Future<String?> _login(String login, String password) async {
//     try {
//       await _authService.login(login, password);
//     } on ApiClientException catch (e) {
//       switch (e.type) {
//         case ApiClientExceptionType.network:
//           return 'Сервер не доступен, проверьте подключение к интернету!';
//         case ApiClientExceptionType.auth:
//           return 'Неверный логин или пароль!';
//         case ApiClientExceptionType.other:
//           return 'Произошла ошибка, попробуйте ещё!';
//         case ApiClientExceptionType.sessionExpired:
//           return 'Произошла ошибка, попробуйте ещё!';
//       }
//     } catch (e) {
//       return 'Неизвестная ошибка, повторите попытку!';
//     }

//     return null;
//   }

//   Future<void> auth(BuildContext context) async {
//     final login = loginTextController.text;
//     final password = passwordTextController.text;

//     if (!_isValidLoginAndPassword(login, password)) {
//       _updateState('Заполните логин и пароль!', false);
//       return;
//     }
//     _updateState(null, true);

//     _errorMessage = await _login(login, password);
//     if (_errorMessage == null) {
//       MainNavigation.resetNavigation(context);
//     } else {
//       _updateState(_errorMessage, false);
//     }
//   }

//   void _updateState(String? errorMessage, bool isAuthProgress) {
//     if (_errorMessage == errorMessage && _isAuthProgress == isAuthProgress) {
//       return;
//     }
//     _errorMessage = errorMessage;
//     _isAuthProgress = isAuthProgress;
//     notifyListeners();
//   }
// }
