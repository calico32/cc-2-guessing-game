import 'package:flutter/material.dart';
import 'package:guessing_game/utils.dart';

import 'gamedata.dart';
import 'state.dart';

class Playing extends StatefulWidget {
  final Function(GameData) onFinish;
  final GameData gameData;

  Playing({this.onFinish, this.gameData});

  @override
  _PlayingState createState() => _PlayingState();
}

class _PlayingState extends State<Playing> {
  int _lastGuess;
  String _message;
  PlayHint _playHint;
  String _error;
  int _previousState;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(numbersOnly(_controller));
    _textFocus.requestFocus();
  }

  void submitGuess(String guess) {
    _error = null;

    var guessValue = int.tryParse(guess);

    if (guessValue == null) {
      setState(() => _error = 'Too large');
      return;
    }

    _lastGuess = guessValue;

    if (guessValue == widget.gameData.targetNumber) {
      // win
      widget.gameData.guesses.add(guessValue);
      widget.onFinish(widget.gameData);
      return;
    }

    setState(() {
      _message = '';
      if (widget.gameData.guesses.contains(guessValue)) {
        _message = "You've already guessed that number!";
      } else {
        widget.gameData.guesses.add(guessValue);
      }

      _playHint = guessValue < widget.gameData.targetNumber
          ? PlayHint.higher
          : PlayHint.lower;

      _controller.value = _controller.value.copyWith(text: '');

      _textFocus.requestFocus();
    });
  }

  WidgetSpan _arrow() {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Icon(
        _playHint == PlayHint.lower ? Icons.arrow_downward : Icons.arrow_upward,
      ),
    );
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(_message),
          ),
        if (widget.gameData.guesses.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text.rich(
              TextSpan(children: [
                _arrow(),
                TextSpan(text: ' The number is '),
                TextSpan(
                  text: _playHint == PlayHint.lower ? 'lower' : 'higher',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' than $_lastGuess '),
                _arrow(),
              ]),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('Make a guess!'),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _controller,
                focusNode: _textFocus,
                keyboardType: TextInputType.number,
                onSubmitted: submitGuess,
                onChanged: (text) {
                  var parsed = int.tryParse(text);
                  if (parsed == null && _previousState != null) {
                    setState(() => _error = 'Too large');
                  } else if (parsed != null && _previousState == null) {
                    setState(() => _error = null);
                  }
                  _previousState = parsed;
                },
                autocorrect: false,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Guess',
                  errorText: _error,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => submitGuess(_controller.text),
              ),
            ),
          ],
        )
      ],
    );
  }
}
