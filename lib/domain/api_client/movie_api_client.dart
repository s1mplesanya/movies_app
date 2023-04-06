import 'package:lesson3/configuration/configuration.dart';
import 'package:lesson3/domain/api_client/network_client.dart';
import 'package:lesson3/domain/entity/movie_details.dart';
import 'package:lesson3/domain/entity/popular_movie_response.dart';

class MovieApiClient {
  final _networkClient = NetWorkClient();

  Future<PopularMovieResponse> getPopularMovies(
      int page, String language, String apiKey) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result =
        _networkClient.get('/movie/popular', parser, <String, dynamic>{
      'api_key': apiKey,
      'language': language,
      'page': page.toString(),
    });
    return result;
  }

  Future<PopularMovieResponse> searchMovies(
      int page, String language, String query, String apiKey) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result =
        _networkClient.get('/search/movie', parser, <String, dynamic>{
      'api_key': apiKey,
      'language': language,
      'page': page.toString(),
      'query': query,
      'include_adult': true.toString(),
    });
    return result;
  }

  Future<MovieDetails> movieDetails(int movieId, String language) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = MovieDetails.fromJson(jsonMap);
      return response;
    }

    final result =
        _networkClient.get('/movie/$movieId', parser, <String, dynamic>{
      'append_to_response': 'credits, videos',
      'api_key': Configuration.apiKey,
      'language': language,
    });
    return result;
  }

  Future<bool> isFavorite(int movieId, String sessionId) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['favorite'] as bool;
      return result;
    }

    final result = _networkClient
        .get('/movie/$movieId/account_states', parser, <String, dynamic>{
      'api_key': Configuration.apiKey,
      'session_id': sessionId,
    });
    return result;
  }
}
