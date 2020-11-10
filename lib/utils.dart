import 'package:flutter/material.dart';

void Function() numbersOnly(TextEditingController controller) {
  return () {
    final text = controller.text
        .split('')
        .where((char) => '0123456789'.contains(char))
        .join('');

    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
      composing: TextRange.empty,
    );
  };
}

Widget numberInput({
  TextEditingController controller,
  InputDecoration decoration,
}) =>
    Container(
      constraints: BoxConstraints(maxHeight: 100, maxWidth: 150),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          decoration: decoration,
          keyboardType: TextInputType.number,
          autocorrect: false,
        ),
      ),
    );
