import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

import 'package:lesson3/domain/blocs/movie_list_bloc.dart';
import 'package:lesson3/domain/entity/movie.dart';

class MovieListRowData {
  final int id;
  final String title;
  final String releaseDate;
  final String overview;
  final String? posterPath;

  MovieListRowData({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.posterPath,
  });
}

class MovieListCubitState {
  final List<MovieListRowData> movies = [];
  final String localeTag;

  MovieListCubitState(
    movies, {
    required this.localeTag,
  });

  @override
  bool operator ==(covariant MovieListCubitState other) {
    if (identical(this, other)) return true;

    return other.localeTag == localeTag;
  }

  @override
  int get hashCode => localeTag.hashCode;

  MovieListCubitState copyWith({
    List<MovieListRowData>? movies,
    String? localeTag,
  }) {
    return MovieListCubitState(
      movies ?? this.movies,
      localeTag: localeTag ?? this.localeTag,
    );
  }
}

class MovieListCubit extends Cubit<MovieListCubitState> {
  final MovieListBloc movieListBloc;
  late DateFormat _dateFormat;
  Timer? searchDebounce;

  late final StreamSubscription<MovieListState> movieListBlocSubscription;

  MovieListCubit(this.movieListBloc)
      : super(MovieListCubitState(
          <MovieListRowData>[],
          localeTag: "",
        )) {
    Future.microtask(() {
      _onState(movieListBloc.state);
      movieListBlocSubscription = movieListBloc.stream.listen(_onState);
    });
  }

  void _onState(MovieListState movieState) {
    final movies = movieState.movies.map(_makeRowData).toList();
    final newState = state.copyWith(movies: movies);
    emit(newState);
  }

  @override
  Future<void> close() {
    movieListBlocSubscription.cancel();
    return super.close();
  }

  void showMovieAtIndex(int index) {
    if (index < state.movies.length - 1) return;
    movieListBloc.add(MovieListLoadNextPageEvent(locale: state.localeTag));
  }

  void setUpLocale(String locale) {
    if (state.localeTag == locale) return;
    final newState = state.copyWith(localeTag: locale);
    emit(newState);

    _dateFormat = DateFormat.yMMMMd(state.localeTag);
    movieListBloc.add(MovieListResetEvent(locale: locale));
    movieListBloc.add(MovieListLoadNextPageEvent(locale: locale));
  }

  MovieListRowData _makeRowData(Movie movie) {
    final releaseDate = movie.releaseDate;
    final releaseDateTitle =
        releaseDate != null ? _dateFormat.format(releaseDate) : '';
    return MovieListRowData(
      id: movie.id,
      title: movie.title,
      releaseDate: releaseDateTitle,
      overview: movie.overview,
      posterPath: movie.posterPath,
    );
  }

  void searchMovie(String text) async {
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(seconds: 1), () async {
      movieListBloc
          .add(MovieListSearchMovieEvent(query: text, locale: state.localeTag));
      movieListBloc.add(MovieListLoadNextPageEvent(locale: state.localeTag));
    });
  }
}
