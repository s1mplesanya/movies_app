import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lesson3/domain/blocs/auth_bloc.dart';

enum LoaderViewCubicState {
  unknown,
  authorized,
  unauthorized,
}

class LoaderViewCubit extends Cubit<LoaderViewCubicState> {
  final AuthBloc authBloc;

  late final StreamSubscription<AuthState> authBlocSubscription;

  LoaderViewCubit(super.initialState, this.authBloc) {
    Future.microtask(() {
      authBloc.add(AuthCheckEvent());
      _onState(authBloc.state);
      authBlocSubscription = authBloc.stream.listen(_onState);
    });
  }

  void _onState(AuthState authState) {
    if (state is AuthAuthorizedState) {
      emit(LoaderViewCubicState.authorized);
    } else if (state is AuthUnauthorizedState) {
      emit(LoaderViewCubicState.unauthorized);
    }
  }

  @override
  Future<void> close() {
    authBlocSubscription.cancel();
    return super.close();
  }
}
