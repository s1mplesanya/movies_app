import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lesson3/Theme/app_button_style.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';
import 'package:lesson3/ui/widgets/auth/auth_view_cubit.dart';
import 'package:provider/provider.dart';

class _AuthDataStorage {
  String login = "";
  String password = "";
}

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthViewCubic, AuthViewCubicState>(
      listener: _onAuthViewCubicStateChange,
      listenWhen: (previous, current) => current is AuthViewCubicSuccessState,
      child: Provider(
        create: (_) => _AuthDataStorage(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Login to your account'),
          ),
          body: ListView(
            children: const [
              _HeaderWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _onAuthViewCubicStateChange(
    BuildContext context,
    AuthViewCubicState state,
  ) {
    if (state is AuthViewCubicSuccessState) {
      MainNavigation.resetNavigation(context);
    }
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25,
          ),
          const _FormWidget(),
          const SizedBox(
            height: 25,
          ),
          const Text(
            'addawadjwjdandwhwadbnkadjwnjakwdnajkwdnajkwdnajkdnajwkdbnajk addawadjwjdandwhwadbnkadjwnjakwdnajkwdnajkwdnajkdnajwkdbnajk addawadjwjdandwhwadbnkadjwnjakwdnajkwdnajkwdnajkdnajwkdbnajkv',
            style: textStyle,
          ),
          TextButton(
            onPressed: () {},
            style: AppButtonStyle.linkButton,
            child: const Text('Register'),
          ),
          const SizedBox(
            height: 25,
          ),
          const Text(
              'addawadjwjdandwhwadbnkadjwnjakwdnajkwdnajkwdnajkdnajwkdbnajk bajw dbkja bdkj ab dkjba w kaj dja',
              style: textStyle),
          TextButton(
            onPressed: () {},
            style: AppButtonStyle.linkButton,
            child: const Text('Verify Email'),
          ),
        ],
      ),
    );
  }
}

class _FormWidget extends StatelessWidget {
  const _FormWidget();

  @override
  Widget build(BuildContext context) {
    final authDataStorage = context.read<_AuthDataStorage>();
    const textStyle = TextStyle(color: Color(0xFF212529), fontSize: 16);
    const mainColor = Color(0xFF01B4E4);
    const textFieldDecorator = InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      isCollapsed: true,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ErrorMessageWidget(),
        const Text(
          'Username',
          style: textStyle,
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          decoration: textFieldDecorator,
          onChanged: (value) => authDataStorage.login = value,
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Password',
          style: textStyle,
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          obscureText: true,
          decoration: textFieldDecorator,
          onChanged: (value) => authDataStorage.password = value,
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          children: [
            const _AuthButtonWidget(),
            const SizedBox(
              width: 30,
            ),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(mainColor),
                textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              ),
              child: const Text('Reset Password'),
            ),
          ],
        )
      ],
    );
  }
}

class _AuthButtonWidget extends StatelessWidget {
  const _AuthButtonWidget();

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF01B4E4);
    final authDataStorage = context.read<_AuthDataStorage>();
    final cubit = context.watch<AuthViewCubic>();

    final canStartAuth = cubit.state is AuthViewCubicFormFillInProgressState ||
        cubit.state is AuthViewCubicErrorState;

    final onPressed = canStartAuth
        ? () => cubit.auth(
              context,
              login: authDataStorage.login,
              password: authDataStorage.password,
            )
        : null;
    final child = cubit.state is AuthViewCubicAuthProgressState
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          )
        : const Text('Login');
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(mainColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          )),
      child: child,
    );
  }
}

class _ErrorMessageWidget extends StatelessWidget {
  const _ErrorMessageWidget();

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select((AuthViewCubic c) {
      final state = c.state;
      if (state is AuthViewCubicErrorState) {
        return state.errorMessage;
      } else {
        null;
      }
    });
    if (errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 17),
      ),
    );
  }
}
