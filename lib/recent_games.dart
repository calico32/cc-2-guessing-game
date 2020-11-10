import 'dart:convert';

import 'package:hive/hive.dart';

import 'constants.dart';
import 'gamedata.dart';

// hive typeadapters do exist but i'm already familiar with json_serializable so
// no

class RecentGamesProvider {
  final Box _box = Hive.box(GUESSING_GAME_BOX);
  final List<GameData> _games = [];

  List<GameData> get games {
    _populate();
    return List.unmodifiable(_games);
  }

  RecentGamesProvider() {
    _populate();
  }

  void _populate() {
    _games.clear();
    [0, 1, 2].forEach((index) {
      var game = _box.get('recent_game_$index');
      if (!(game is String)) {
        _box.delete('recent_game_$index');
        game = null;
      }
      _games.add(
        game == null ? null : GameData.fromJson(jsonDecode(game)),
      );
    });
  }

  void _saveGames() {
    _games.asMap().entries.forEach((e) {
      if (e.value == null) return _box.delete('recent_game_${e.key}');

      _box.put('recent_game_${e.key}', jsonEncode(e.value.toJson()));
    });
  }

  void pushNew(GameData game) {
    _populate();
    print('new game: ${jsonEncode(game.toJson())}');
    _games.insert(0, game);
    _games.removeLast();
    _saveGames();
  }

  void clear() {
    _games.setAll(0, [null, null, null]);
    _saveGames();
  }
}
