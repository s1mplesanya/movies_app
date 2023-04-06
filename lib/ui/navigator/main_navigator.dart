import 'package:flutter/material.dart';
import 'package:lesson3/domain/factories/screen_factory.dart';

class MainNavigationRoutesName {
  static const loaderScreen = '/';
  static const auth = '/auth';
  static const mainScreen = '/main_screen';
  static const movieDetails = '/main_screen/movie_details';
  static const movieTrailer = '/main_screen/movie_details/trailer';
}

class MainNavigation {
  static final _screenFactory = ScreenFactory();

  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRoutesName.loaderScreen: (_) => _screenFactory.makeLoader(),
    MainNavigationRoutesName.auth: (_) => _screenFactory.makeAuth(),
    MainNavigationRoutesName.mainScreen: (_) => _screenFactory.makeMainScreen(),
  };

  Route<Object>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRoutesName.movieDetails:
        final arguments = settings.arguments;
        final movieId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
            builder: (_) => _screenFactory.makeMovieDetails(movieId));
      case MainNavigationRoutesName.movieTrailer:
        final arguments = settings.arguments;
        final youtubeKey = arguments is String ? arguments : '';
        return MaterialPageRoute(
            builder: (_) => _screenFactory.makeMovieTrailer(youtubeKey));

      default:
        const widget = Text('Nagivation error!');
        return MaterialPageRoute(builder: (_) => widget);
    }
  }

  static void resetNavigation(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        MainNavigationRoutesName.loaderScreen, (route) => false);
  }
}
