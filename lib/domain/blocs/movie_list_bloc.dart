// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lesson3/configuration/configuration.dart';
import 'package:lesson3/domain/api_client/movie_api_client.dart';
import 'package:lesson3/domain/entity/movie.dart';
import 'package:lesson3/domain/entity/popular_movie_response.dart';

abstract class MovieListEvent {}

class MovieListLoadNextPageEvent extends MovieListEvent {
  final String locale;
  MovieListLoadNextPageEvent({
    required this.locale,
  });
}

class MovieListResetEvent extends MovieListEvent {
  final String locale;
  MovieListResetEvent({
    required this.locale,
  });
}

class MovieListSearchMovieEvent extends MovieListEvent {
  final String query;
  final String locale;

  MovieListSearchMovieEvent({
    required this.query,
    required this.locale,
  });
}

class MovieListContainer {
  final List<Movie> movies;
  final int currentPage;
  final int totalPage;

  bool get isComplete => currentPage >= totalPage;

  const MovieListContainer.initialState()
      : movies = const <Movie>[],
        currentPage = 0,
        totalPage = 1;

  MovieListContainer({
    required this.movies,
    required this.currentPage,
    required this.totalPage,
  });

  MovieListContainer copyWith({
    List<Movie>? movies,
    int? currentPage,
    int? totalPage,
  }) {
    return MovieListContainer(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }

  @override
  bool operator ==(covariant MovieListContainer other) {
    if (identical(this, other)) return true;

    return listEquals(other.movies, movies) &&
        other.currentPage == currentPage &&
        other.totalPage == totalPage;
  }

  @override
  int get hashCode =>
      movies.hashCode ^ currentPage.hashCode ^ totalPage.hashCode;
}

class MovieListState {
  final MovieListContainer popularMovieContainer;
  final MovieListContainer searchMovieContainer;
  final String searchQuery;

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<Movie> get movies =>
      isSearchMode ? searchMovieContainer.movies : popularMovieContainer.movies;

  const MovieListState.initialState()
      : popularMovieContainer = const MovieListContainer.initialState(),
        searchMovieContainer = const MovieListContainer.initialState(),
        searchQuery = "";

  MovieListState({
    required this.popularMovieContainer,
    required this.searchMovieContainer,
    required this.searchQuery,
  });

  MovieListState copyWith({
    MovieListContainer? popularMovieContainer,
    MovieListContainer? searchMovieContainer,
    String? searchQuery,
  }) {
    return MovieListState(
      popularMovieContainer:
          popularMovieContainer ?? this.popularMovieContainer,
      searchMovieContainer: searchMovieContainer ?? this.searchMovieContainer,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(covariant MovieListState other) {
    if (identical(this, other)) return true;

    return other.popularMovieContainer == popularMovieContainer &&
        other.searchMovieContainer == searchMovieContainer &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode =>
      popularMovieContainer.hashCode ^
      searchMovieContainer.hashCode ^
      searchQuery.hashCode;
}

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final _movieApiClient = MovieApiClient();

  MovieListBloc(super.initialState) {
    on<MovieListEvent>(
      (event, emit) async {
        if (event is MovieListLoadNextPageEvent) {
          await onMovieListLoadNextPageEvent(event, emit);
        } else if (event is MovieListResetEvent) {
          await onMovieListResetEvent(event, emit);
        } else if (event is MovieListSearchMovieEvent) {
          await onMovieListSearchMovieEvent(event, emit);
        }
      },
      transformer: sequential(),
    );
  }

  Future<void> onMovieListLoadNextPageEvent(
    MovieListLoadNextPageEvent event,
    Emitter<MovieListState> emitter,
  ) async {
    if (state.isSearchMode) {
      final newContainer =
          await _loadNextPage(state.searchMovieContainer, (nextPage) async {
        final result = await _movieApiClient.getPopularMovies(
            nextPage, event.locale, Configuration.apiKey);
        return result;
      });
      if (newContainer != null) {
        final newState = state.copyWith(searchMovieContainer: newContainer);
        emit(newState);
      }
    } else {
      final newContainer =
          await _loadNextPage(state.searchMovieContainer, (nextPage) async {
        final result = await _movieApiClient.getPopularMovies(
          nextPage,
          event.locale,
          Configuration.apiKey,
        );
        return result;
      });
      if (newContainer != null) {
        final newState = state.copyWith(popularMovieContainer: newContainer);
        emit(newState);
      }
    }
  }

  Future<MovieListContainer?> _loadNextPage(
    MovieListContainer container,
    Future<PopularMovieResponse> Function(int) loader,
  ) async {
    if (container.isComplete) return null;
    final nextPage = container.currentPage + 1;
    final result = await loader(nextPage);

    final movies = List<Movie>.from(container.movies)..addAll(result.movies);
    final newContainer = container.copyWith(
      movies: movies,
      currentPage: result.page,
      totalPage: result.totalPages,
    );
    return newContainer;
  }

  Future<void> onMovieListResetEvent(
    MovieListResetEvent event,
    Emitter<MovieListState> emitter,
  ) async {
    emit(const MovieListState.initialState());
    add(MovieListLoadNextPageEvent(locale: event.locale));
  }

  Future<void> onMovieListSearchMovieEvent(
    MovieListSearchMovieEvent event,
    Emitter<MovieListState> emitter,
  ) async {
    if (state.searchQuery == event.query) return;
    final newState = state.copyWith(
      searchQuery: event.query,
      searchMovieContainer: const MovieListContainer.initialState(),
    );
    add(MovieListLoadNextPageEvent(locale: event.locale));
  }
}
