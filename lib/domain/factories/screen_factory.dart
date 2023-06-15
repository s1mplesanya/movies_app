import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lesson3/domain/blocs/auth_bloc.dart';
import 'package:lesson3/domain/blocs/movie_list_bloc.dart';
import 'package:lesson3/ui/widgets/auth/auth_view_cubit.dart';
import 'package:lesson3/ui/widgets/auth/auth_widget.dart';
import 'package:lesson3/ui/widgets/loader/loader_view_cubit.dart';
import 'package:lesson3/ui/widgets/loader/loader_widget.dart';
import 'package:lesson3/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:lesson3/ui/widgets/movie_details/movie_details_model.dart';
import 'package:lesson3/ui/widgets/movie_details/movie_details_widget.dart';
import 'package:lesson3/ui/widgets/movie_list/movie_list_cubit.dart';
import 'package:lesson3/ui/widgets/movie_list/movie_list_widget.dart';
import 'package:lesson3/ui/widgets/movie_trailer/movie_trailer_widget.dart';
import 'package:provider/provider.dart';

class ScreenFactory {
  AuthBloc? _authBloc;

  Widget makeLoader() {
    final authBloc = _authBloc ?? AuthBloc(AuthCheckInProgressState());
    _authBloc = authBloc;

    return BlocProvider<LoaderViewCubit>(
      create: (context) => LoaderViewCubit(
        LoaderViewCubicState.unknown,
        authBloc,
      ),
      lazy: false,
      child: const LoaderWidget(),
    );
  }

  Widget makeAuth() {
    final authBloc = _authBloc ?? AuthBloc(AuthCheckInProgressState());
    _authBloc = authBloc;

    return BlocProvider<AuthViewCubic>(
      create: (context) => AuthViewCubic(
        AuthViewCubicFormFillInProgressState(),
        authBloc: authBloc,
      ),
      child: const AuthWidget(),
    );
  }

  Widget makeMainScreen() {
    _authBloc?.close();
    _authBloc = null;
    return const MainScreenWidget();
  }

  Widget makeMovieDetails(int movieId) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailsModel(movieId),
      child: const MovieDetailsWidget(),
    );
  }

  Widget makeMovieTrailer(String youtubeKey) {
    return MovieTrailerWidget(
      youtubeKey: youtubeKey,
    );
  }

  Widget makeNewsList() {
    return const Text('Новости');
  }

  Widget makeMovieList() {
    return BlocProvider<MovieListCubit>(
      create: (context) => MovieListCubit(
        MovieListBloc(const MovieListState.initialState()),
      ),
      child: const MovieListWidget(),
    );
  }

  Widget makeSeriesList() {
    return const Text('Сериалы');
  }
}
