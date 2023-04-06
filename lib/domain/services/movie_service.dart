import 'package:lesson3/configuration/configuration.dart';
import 'package:lesson3/domain/api_client/account_api_client.dart';
import 'package:lesson3/domain/api_client/movie_api_client.dart';
import 'package:lesson3/domain/data_providers/session_data_provider.dart';
import 'package:lesson3/domain/entity/popular_movie_response.dart';
import 'package:lesson3/domain/local_entity/movie_details_local.dart';

class MovieService {
  final _movieApiClient = MovieApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();

  Future<PopularMovieResponse> popularMovie(int page, String language) async =>
      _movieApiClient.getPopularMovies(page, language, Configuration.apiKey);

  Future<PopularMovieResponse> searchMovie(
          int page, String language, String query) async =>
      _movieApiClient.searchMovies(page, language, query, Configuration.apiKey);

  Future<MovieDetailsLocal> getMovieDetails(
      {required int movieId, required String locale}) async {
    final movieDetails = await _movieApiClient.movieDetails(movieId, locale);
    final sessionId = await _sessionDataProvider.getSessionId();
    var isFavorite = false;

    if (sessionId != null) {
      isFavorite = await _movieApiClient.isFavorite(movieId, sessionId);
    }

    return MovieDetailsLocal(details: movieDetails, isFavorite: isFavorite);
  }

  Future<void> updateFavorite({
    required int movieId,
    required bool isFavorite,
  }) async {
    final accountId = await _sessionDataProvider.getAccountId();
    final sessionId = await _sessionDataProvider.getSessionId();

    if (accountId == null || sessionId == null) return;

    await _accountApiClient.markAsFavorite(
        accountId: accountId,
        sessionId: sessionId,
        mediaType: MediaType.movie,
        mediaId: movieId,
        isFavorite: isFavorite);
  }
}
