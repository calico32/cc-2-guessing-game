import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:guessing_game/recent_games.dart';

import 'gamedata.dart';
import 'line_chart.dart';
import 'utils.dart';

class NotPlaying extends StatefulWidget {
  final bool finished;
  final GameData gameData;
  final Function(int min, int max) onStart;

  NotPlaying({
    this.finished = false,
    this.gameData,
    this.onStart,
  }) {
    if (finished) assert(gameData != null);
  }

  @override
  _NotPlayingState createState() => _NotPlayingState(
        finished: finished,
        gameData: gameData,
      );
}

class _NotPlayingState extends State<NotPlaying> {
  final TextEditingController _min = TextEditingController();
  final TextEditingController _max = TextEditingController();
  String _minErrorText;
  String _maxErrorText;
  final RecentGamesProvider _recentGames = RecentGamesProvider();
  bool finished;
  GameData gameData;

  _NotPlayingState({@required this.finished, @required this.gameData}) {
    print('new not playing');
    if (finished) {
      _recentGames.pushNew(gameData);
    }
  }

  @override
  void initState() {
    super.initState();
    _min.addListener(numbersOnly(_min));
    _max.addListener(numbersOnly(_max));

    var min = '1';
    var max = '100';
    if (finished) {
      min = gameData.min.toString();
      max = gameData.max.toString();
    }
    _min.value = _min.value.copyWith(text: min);
    _max.value = _max.value.copyWith(text: max);
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void validate() {
    var min = int.tryParse(_min.text);
    var max = int.tryParse(_max.text);
    var shouldReturn = false;
    var callbacks = <Function()>[];
    void returnIf(bool Function() fn, [Function() callback]) {
      if (fn()) {
        callbacks.add(callback);
        shouldReturn = true;
      }
    }

    _minErrorText = null;
    _maxErrorText = null;

    returnIf(() => min == null, () => _minErrorText = 'Invalid integer');
    returnIf(() => max == null, () => _maxErrorText = 'Invalid integer');
    returnIf(() => min != null && max != null && max < min,
        () => _maxErrorText = 'Maximium cannot be greater than minimum');
    returnIf(() => min != null && max != null && max - min > 1 << 32,
        () => _maxErrorText = 'Too large');

    if (shouldReturn) {
      setState(() => callbacks.forEach((cb) => cb()));
      return;
    }

    widget.onStart(min, max);
  }

  // Map<DateTime, double> _horizontal(int lastX, int y) => {
  //       DateTime(0): y.toDouble(),
  //       DateTime(0, lastX): y.toDouble(),
  //     };

  Widget info(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (finished) ...[
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'The number was '),
                TextSpan(
                  text: gameData.targetNumber.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '!'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'You reached the answer in '),
                  TextSpan(
                    text: gameData.guesses.length.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' guess' + (gameData.guesses.length > 1 ? 'es' : ''),
                  ),
                ],
              ),
            ),
          )
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('Welcome!'),
          )
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              numberInput(
                controller: _min,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Minimum',
                  errorText: _minErrorText,
                  errorMaxLines: 2,
                ),
              ),
              numberInput(
                controller: _max,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Maximum',
                  errorText: _maxErrorText,
                  errorMaxLines: 2,
                ),
              ),
            ],
          ),
        ),
        RaisedButton.icon(
          icon: Icon(Icons.play_arrow_outlined),
          label: Text('START'),
          color: Theme.of(context).accentColor,
          textColor: Theme.of(context).accentTextTheme.button.color,
          onPressed: validate,
        ),
        if (_recentGames.games.any((g) => g != null)) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text('Recent games:'),
          ),
          Text.rich(
            TextSpan(
              children: [
                for (final game
                    in _recentGames.games.where((g) => g != null)) ...[
                  TextSpan(
                    text: game.targetNumber.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' in the range '),
                  TextSpan(
                    text: '${game.min}-${game.max}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' in '),
                  TextSpan(
                    text: game.guesses.length.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' guess${game.guesses.length > 1 ? 'es' : ''}\n',
                  )
                ],
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ]
      ],
    );
  }

  @override
  Widget build(context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: info(context),
        ),
        if (gameData != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: LineChart(makeLineChart(gameData)),
          ),
      ],
    );
  }
}
