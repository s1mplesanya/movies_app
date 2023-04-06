import 'package:flutter/material.dart';
import 'package:lesson3/domain/data_providers/session_data_provider.dart';
import 'package:lesson3/domain/factories/screen_factory.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({super.key});

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedPage = 0;

  final _screenFactory = ScreenFactory();

  void onSelectPage(int index) {
    if (_selectedPage == index) return;
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDB'),
        actions: [
          IconButton(
              onPressed: () => SessionDataProvider().deleteSessionId(),
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: IndexedStack(
        index: _selectedPage,
        children: [
          _screenFactory.makeNewsList(),
          _screenFactory.makeMovieList(),
          _screenFactory.makeSeriesList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.newspaper), label: "Новости"),
            BottomNavigationBarItem(
                icon: Icon(Icons.movie_filter), label: "Фильмы"),
            BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Сериалы"),
          ],
          onTap: onSelectPage),
    );
  }
}
