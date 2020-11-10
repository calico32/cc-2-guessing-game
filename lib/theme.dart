import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'constants.dart';

// singleton theme instance
ThemeProvider theme = ThemeProvider();

const String _hiveDarkEnabled = 'dark_theme_enabled';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  Box _box;

  ThemeData _commonTheme(ThemeData base, ThemeMode mode) => base.copyWith(
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.transparent,
        // accentColor: Colors.tealAccent,
        // accentColorBrightness: Brightness.light,
        // primaryColor: Colors.tealAccent,
        // primaryColorBrightness: Brightness.light,

        buttonTheme: ButtonThemeData(
          buttonColor: base.accentColor,
          textTheme: ButtonTextTheme.primary,
        ),
      );

  ThemeData get light => _commonTheme(ThemeData.light(), ThemeMode.light);
  ThemeData get dark => _commonTheme(ThemeData.dark(), ThemeMode.dark);

  ThemeProvider() {
    _box = Hive.box(GUESSING_GAME_BOX);

    if (_box.containsKey(_hiveDarkEnabled)) {
      _isDark = _box.get(_hiveDarkEnabled);
    } else {
      _isDark = true;
      _box.put(_hiveDarkEnabled, true);
    }
  }

  ThemeMode get current => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
    _box.put(_hiveDarkEnabled, _isDark);
  }
}
