import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';
import 'package:lesson3/ui/widgets/loader/loader_view_cubit.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoaderViewCubit, LoaderViewCubicState>(
      listener: _onLoaderViewCubicStateChange,
      listenWhen: (previous, current) =>
          current != LoaderViewCubicState.unknown,
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _onLoaderViewCubicStateChange(
    BuildContext context,
    LoaderViewCubicState state,
  ) {
    final nextScreen = state == LoaderViewCubicState.authorized
        ? MainNavigationRoutesName.mainScreen
        : MainNavigationRoutesName.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
