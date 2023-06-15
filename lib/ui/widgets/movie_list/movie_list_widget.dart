import 'package:flutter/material.dart';
import 'package:lesson3/domain/api_client/image_dowloader.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';
import 'package:lesson3/ui/widgets/movie_list/movie_list_cubit.dart';
import 'package:provider/provider.dart';

class MovieListWidget extends StatefulWidget {
  const MovieListWidget({super.key});

  @override
  State<MovieListWidget> createState() => _MovieListWidgetState();
}

class _MovieListWidgetState extends State<MovieListWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context);
    context.read<MovieListCubit>().setUpLocale(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _MovieLIstView(),
        _SearchMovieWidget(),
      ],
    );
  }
}

class _SearchMovieWidget extends StatelessWidget {
  const _SearchMovieWidget();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieListCubit>();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        onChanged: cubit.searchMovie,
        // controller: _searchController,
        decoration: InputDecoration(
            labelText: 'Поиск',
            filled: true,
            fillColor: Colors.white.withAlpha(235),
            border: const OutlineInputBorder()),
      ),
    );
  }
}

class _MovieLIstView extends StatelessWidget {
  const _MovieLIstView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MovieListCubit>();
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 70),
      itemCount: cubit.state.movies.length,
      itemExtent: 163,
      itemBuilder: (BuildContext context, int index) {
        cubit.showMovieAtIndex(index);
        return _MovieListRow(index: index);
      },
    );
  }
}

class _MovieListRow extends StatelessWidget {
  final int index;
  const _MovieListRow({required this.index});

  void _onMovieTap(BuildContext context, int id) {
    Navigator.of(context)
        .pushNamed(MainNavigationRoutesName.movieDetails, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieListCubit>();
    final movie = cubit.state.movies[index];
    final posterPath = movie.posterPath;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () => _onMovieTap(context, movie.id),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black.withOpacity(0.2)),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                if (posterPath != null)
                  Image.network(
                    ImageDownloader.imageUrl(posterPath),
                    width: 95,
                  ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        movie.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        movie.releaseDate,
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        movie.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
