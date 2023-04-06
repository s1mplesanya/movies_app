import 'package:flutter/material.dart';
import 'package:lesson3/domain/api_client/image_dowloader.dart';
import 'package:lesson3/domain/entity/movie_details_credits.dart';
import 'package:lesson3/ui/navigator/main_navigator.dart';
import 'package:lesson3/ui/widgets/movie_details/movie_details_model.dart';
import 'package:provider/provider.dart';

import '../elements/radial_percent_widget.dart';

class MovieDetailsMainInfoWidget extends StatelessWidget {
  const MovieDetailsMainInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _TopPosters(),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: _MovieNameWidget(),
        ),
        _ScoreWidget(),
        _SummaryWidget(),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: _OverViewWidget(),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: _DescriptionWidget(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _PeopleWidget(),
        ),
      ],
    );
  }
}

class _OverViewWidget extends StatelessWidget {
  const _OverViewWidget();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Overview',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget();

  @override
  Widget build(BuildContext context) {
    final overview =
        context.select((MovieDetailsModel model) => model.data.overview);
    return Text(
      overview,
      style: const TextStyle(color: Colors.white),
    );
  }
}

class _TopPosters extends StatelessWidget {
  const _TopPosters();

  @override
  Widget build(BuildContext context) {
    final model = context.read<MovieDetailsModel>();
    final posterData =
        context.select((MovieDetailsModel md) => md.data.posterData);
    final backdropPath = posterData.backdropPath ?? '';
    final posterPath = posterData.posterPath ?? '';
    return AspectRatio(
      aspectRatio: 390 / 219,
      child: Stack(
        children: [
          if (backdropPath != null)
            Image.network(ImageDownloader.imageUrl(backdropPath)),
          if (posterPath != null)
            Positioned(
                top: 20,
                left: 20,
                bottom: 20,
                child: SizedBox(
                    width: 80,
                    height: 120,
                    child:
                        Image.network(ImageDownloader.imageUrl(posterPath)))),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: Icon(posterData.favoriteIcon),
              onPressed: () => model.toggleFavorite(context),
            ),
          )
        ],
      ),
    );
  }
}

class _MovieNameWidget extends StatelessWidget {
  const _MovieNameWidget();

  @override
  Widget build(BuildContext context) {
    final data = context.select((MovieDetailsModel md) => md.data.nameData);
    return Center(
      child: RichText(
        maxLines: 3,
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
              text: data.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
          TextSpan(
              text: data.year,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
        ]),
      ),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  const _ScoreWidget();

  @override
  Widget build(BuildContext context) {
    final scoreData =
        context.select((MovieDetailsModel model) => model.data.scoreData);

    final trailerKey = scoreData.trailerKey;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: RadialPercentWidget(
                  percent: scoreData.voteAverage / 10,
                  fillColor: const Color.fromARGB(255, 10, 23, 25),
                  lineColor: const Color.fromARGB(255, 37, 203, 103),
                  freeColor: const Color.fromARGB(255, 25, 54, 31),
                  lineWeight: 3,
                  child: Text(
                    (scoreData.voteAverage * 10).toStringAsFixed(0),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Text('Score'),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 15,
          color: Colors.grey,
        ),
        if (trailerKey != null)
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
                MainNavigationRoutesName.movieTrailer,
                arguments: trailerKey),
            child: Row(
              children: const [
                Icon(Icons.play_arrow),
                Text('Play Trayler'),
              ],
            ),
          )
      ],
    );
  }
}

class _SummaryWidget extends StatelessWidget {
  const _SummaryWidget();

  @override
  Widget build(BuildContext context) {
    final summary = context.select((MovieDetailsModel md) => md.data.summary);

    return ColoredBox(
      color: const Color.fromRGBO(22, 21, 25, 1.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          summary,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PeopleWidget extends StatelessWidget {
  const _PeopleWidget();

  @override
  Widget build(BuildContext context) {
    var crewChunks = context.select((MovieDetailsModel md) => md.data.crewData);
    if (crewChunks.isEmpty) return const SizedBox.shrink();

    return Column(
        children: crewChunks
            .map((chunk) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _PeopleWidgetRow(
                    employes: chunk,
                  ),
                ))
            .toList());
  }
}

class _PeopleWidgetRow extends StatelessWidget {
  final List<MoviePeopleCrewData> employes;
  const _PeopleWidgetRow({required this.employes});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        children: employes
            .map((employee) => _PeopleWidgetRowItem(
                  employee: employee,
                ))
            .toList());
  }
}

class _PeopleWidgetRowItem extends StatelessWidget {
  final MoviePeopleCrewData employee;
  const _PeopleWidgetRowItem({required this.employee});

  @override
  Widget build(BuildContext context) {
    const peoplesTextStyle = TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400);
    const jobTitleTextStyle = TextStyle(
        color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee.name,
            style: peoplesTextStyle,
          ),
          Text(
            employee.job,
            style: jobTitleTextStyle,
          ),
        ],
      ),
    );
  }
}
