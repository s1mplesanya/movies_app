import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lesson3/domain/api_client/api_client_exteption.dart';
import 'package:lesson3/domain/entity/movie_details.dart';
import 'package:lesson3/domain/services/auth_service.dart';
import 'package:lesson3/domain/services/movie_service.dart';
import 'package:lesson3/library/widgets/localized_model.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';

class MovieDetailsPosterData {
  final String? backdropPath;
  final String? posterPath;
  final bool isFavorite;
  IconData get favoriteIcon =>
      isFavorite ? Icons.favorite : Icons.favorite_outline;

  MovieDetailsPosterData({
    this.backdropPath,
    this.posterPath,
    this.isFavorite = false,
  });

  MovieDetailsPosterData copyWith({
    String? backdropPath,
    String? posterPath,
    bool? isFavorite,
  }) {
    return MovieDetailsPosterData(
      backdropPath: backdropPath ?? this.backdropPath,
      posterPath: posterPath ?? this.posterPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MovieNameData {
  final String name;
  final String year;
  MovieNameData({
    required this.name,
    required this.year,
  });
}

class MovieScoreData {
  final double voteAverage;
  final String? trailerKey;
  MovieScoreData({
    required this.voteAverage,
    this.trailerKey,
  });
}

class MoviePeopleCrewData {
  final String name;
  final String job;

  MoviePeopleCrewData({
    required this.name,
    required this.job,
  });
}

class MovieActorData {
  final String name;
  final String character;
  final String? profilePath;

  MovieActorData({
    required this.name,
    required this.character,
    this.profilePath,
  });
}

class MovieDetailsData {
  String title = "";
  bool isLoading = true;
  String overview = "";
  MovieDetailsPosterData posterData = MovieDetailsPosterData();
  MovieNameData nameData = MovieNameData(name: '', year: '');
  MovieScoreData scoreData = MovieScoreData(voteAverage: 0);
  String summary = '';
  List<List<MoviePeopleCrewData>> crewData =
      const <List<MoviePeopleCrewData>>[];

  List<MovieActorData> actorsData = const <MovieActorData>[];
}

class MovieDetailsModel extends ChangeNotifier {
  final _authService = AuthService();
  final _movieService = MovieService();

  final data = MovieDetailsData();

  final int movieId;

  final _localeStorage = LocalizedModelStorage();
  late DateFormat _dateFormat;
  MovieDetailsModel(
    this.movieId,
  );

  Future<void> setUpLocale(BuildContext context, Locale locale) async {
    if (!_localeStorage.updateLocale(locale)) return;
    _dateFormat = DateFormat.yMMMMd(_localeStorage.localeTag);
    updateData(null, false);

    await getMovieDetails(context);
  }

  Future<void> getMovieDetails(BuildContext context) async {
    try {
      final movieDetails = await _movieService.getMovieDetails(
          movieId: movieId, locale: _localeStorage.localeTag);
      updateData(movieDetails.details, movieDetails.isFavorite);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  void updateData(MovieDetails? details, bool isFavorite) {
    data.title = details?.title ?? "Loading...";
    data.isLoading = details == null;
    if (details == null) {
      notifyListeners();
      return;
    }
    data.overview = details.overview ?? '';

    data.posterData = MovieDetailsPosterData(
      isFavorite: isFavorite,
      backdropPath: details.backdropPath,
      posterPath: details.posterPath,
    );

    var year = details.releaseDate?.year.toString();
    year = year != null ? ' ($year)' : '';
    data.nameData = MovieNameData(name: details.title, year: year);

    final videos = details.videos.results
        .where((video) => video.type == 'Trailer' && video.site == 'Youtube');
    final trailerKey = videos.isNotEmpty == true ? videos.first.key : null;
    data.scoreData = MovieScoreData(
        voteAverage: details.voteAverage, trailerKey: trailerKey);

    data.summary = makeSummary(details);
    data.crewData = makeCrewData(details);
    data.actorsData = details.credits.cast
        .map((e) => MovieActorData(
            name: e.name, character: e.character, profilePath: e.profilePath))
        .toList();

    notifyListeners();
  }

  String makeSummary(MovieDetails details) {
    var texts = <String>[];
    final releaseDate = details.releaseDate;
    if (releaseDate != null) {
      texts.add(_dateFormat.format(releaseDate));
    }

    if (details.productionCountries.isNotEmpty) {
      texts.add('(${details.productionCountries.first.iso})');
    }
    final runtime = details.runtime ?? 0;
    final duration = Duration(minutes: runtime);
    texts.add('${duration.inHours}h ${duration.inMinutes}m');

    if (details.genres.isNotEmpty) {
      final genresNames = <String>[];
      for (var gern in details.genres) {
        genresNames.add(gern.name);
      }
      texts.add(genresNames.join(', '));
    }
    return texts.join();
  }

  List<List<MoviePeopleCrewData>> makeCrewData(MovieDetails details) {
    var crew = details.credits.crew
        .map((e) => MoviePeopleCrewData(job: e.job, name: e.name))
        .toList();
    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;

    var crewChunks = <List<MoviePeopleCrewData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunks
          .add(crew.sublist(i, i + 2 > crew.length ? crew.length : i + 2));
    }

    return crewChunks;
  }

  Future<void> toggleFavorite(BuildContext context) async {
    data.posterData.copyWith(isFavorite: !data.posterData.isFavorite);
    notifyListeners();
    try {
      await _movieService.updateFavorite(
          movieId: movieId, isFavorite: data.posterData.isFavorite);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  void _handleApiClientException(
      ApiClientException exception, BuildContext context) {
    switch (exception.type) {
      case ApiClientExceptionType.sessionExpired:
        _authService.logout();
        MainNavigation.resetNavigation(context);
        break;
      default:
        break;
    }
  }
}
