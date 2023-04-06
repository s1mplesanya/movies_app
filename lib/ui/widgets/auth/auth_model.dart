import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lesson3/domain/api_client/api_client_exteption.dart';
import 'package:lesson3/domain/services/auth_service.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';

class AuthViewModel extends ChangeNotifier {
  final loginTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final _authService = AuthService();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthProgress = false;
  bool get canStartAuth => !_isAuthProgress;
  bool get isAuthProgress => _isAuthProgress;

  bool _isValidLoginAndPassword(String login, String password) =>
      login.isNotEmpty && password.isNotEmpty;

  Future<String?> _login(String login, String password) async {
    try {
      await _authService.login(login, password);
    } on ApiClientException catch (e) {
      switch (e.type) {
        case ApiClientExceptionType.network:
          return 'Сервер не доступен, проверьте подключение к интернету!';
        case ApiClientExceptionType.auth:
          return 'Неверный логин или пароль!';
        case ApiClientExceptionType.other:
          return 'Произошла ошибка, попробуйте ещё!';
        case ApiClientExceptionType.sessionExpired:
          return 'Произошла ошибка, попробуйте ещё!';
      }
    } catch (e) {
      return 'Неизвестная ошибка, повторите попытку!';
    }

    return null;
  }

  Future<void> auth(BuildContext context) async {
    final login = loginTextController.text;
    final password = passwordTextController.text;

    if (!_isValidLoginAndPassword(login, password)) {
      _updateState('Заполните логин и пароль!', false);
      return;
    }
    _updateState(null, true);

    _errorMessage = await _login(login, password);
    if (_errorMessage == null) {
      MainNavigation.resetNavigation(context);
    } else {
      _updateState(_errorMessage, false);
    }
  }

  void _updateState(String? errorMessage, bool isAuthProgress) {
    if (_errorMessage == errorMessage && _isAuthProgress == isAuthProgress) {
      return;
    }
    _errorMessage = errorMessage;
    _isAuthProgress = isAuthProgress;
    notifyListeners();
  }
}
