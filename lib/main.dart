import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:guessing_game/recent_games.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';
import 'gamedata.dart';
import 'not_playing.dart';
import 'playing.dart';
import 'state.dart';
import 'theme.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(GUESSING_GAME_BOX);
  runApp(NumberGameApp());
}

class NumberGameApp extends StatefulWidget {
  @override
  _NumberGameAppState createState() => _NumberGameAppState();
}

class _NumberGameAppState extends State<NumberGameApp> {
  @override
  void initState() {
    super.initState();
    // when the theme is reloaded, rebuild
    theme.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guessing Game',
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: theme.current,
      home: NumberGamePage(),
    );
  }
}

class NumberGamePage extends StatefulWidget {
  NumberGamePage({Key key}) : super(key: key);

  @override
  _NumberGamePageState createState() => _NumberGamePageState();
}

class _NumberGamePageState extends State<NumberGamePage> {
  GameState _gameState = GameState.start;
  GameData _gameData;

  void onStart(int min, int max) {
    _gameData = GameData(
      min: min,
      max: max,
      targetNumber: Random().nextInt(max - min) + min,
      guesses: [],
    );

    setState(() => _gameState = GameState.playing);
  }

  void onFinish(GameData gameData) {
    _gameData = gameData;

    setState(() => _gameState = GameState.finished);
  }

  void _aboutDialog(BuildContext context) => showAboutDialog(
        context: context,
        applicationVersion: 'v1.0.0',
        children: [
          Text('by @wiisportsresort'),
          Text(''),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Repository',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => launch(
                          'https://github.com/wiisportsresort/guessing-game',
                        ),
                ),
              ],
            ),
          )
        ],
      );

  Widget _recentGamesDialog() => AlertDialog(
        content: SingleChildScrollView(
          child: Text(
            'Are you sure?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text('CANCEL', textAlign: TextAlign.end),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('YES', textAlign: TextAlign.end),
            onPressed: () {
              RecentGamesProvider().clear();

              setState(() {});

              Navigator.pop(context);
              Navigator.pop(context);
              final snackbar = SnackBar(content: Text('Cleared recent games.'));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            },
          )
        ],
      );

  void _settingsDialog(BuildContext context) => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 300,
            ),
            padding: EdgeInsets.fromLTRB(11.0, 9.0, 11.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                RaisedButton.icon(
                  icon: Icon(Icons.clear),
                  label: Text('Clear recent games'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => _recentGamesDialog(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // brightness: Brightness.light,
        elevation: 0,
        iconTheme: IconThemeData(
          color:
              theme.current == ThemeMode.dark ? Colors.white : Colors.black87,
        ),
        title: Text(
          'Number Guessing Game',
          style: TextStyle(
            color:
                theme.current == ThemeMode.dark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.current == ThemeMode.dark
                  ? Icons.brightness_7
                  : Icons.brightness_5,
            ),
            onPressed: theme.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _aboutDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => _settingsDialog(context),
          )
        ],
      ),
      body: Center(
        child: _gameState == GameState.playing
            ? Playing(
                onFinish: onFinish,
                gameData: _gameData,
              )
            : NotPlaying(
                onStart: onStart,
                gameData: _gameData,
                finished: _gameState == GameState.finished,
              ),
      ),
    );
  }
}
