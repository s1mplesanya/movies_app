import 'package:flutter/material.dart';
import 'package:lesson3/domain/services/auth_service.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';

class LoaderViewModel {
  final _authService = AuthService();
  final BuildContext context;

  LoaderViewModel(this.context) {
    initialize();
  }

  Future<void> initialize() async {
    await checkAuth();
  }

  Future<void> checkAuth() async {
    final isAuth = await _authService.isAuth();
    final nextScreen = isAuth
        ? MainNavigationRoutesName.mainScreen
        : MainNavigationRoutesName.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
