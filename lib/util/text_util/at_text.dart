import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AtText extends SpecialText {
  static const String flag = "@";
  final int start;

  /// whether show background for @somebody
  final bool showAtBackground;

  AtText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.showAtBackground = false, required this.start})
      : super(flag, " ", textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    TextStyle? textStyle =
    this.textStyle?.copyWith(color: Colors.blue, fontSize: 16.0);

    final String atText = toString();

    return showAtBackground
        ? BackgroundTextSpan(
        background: Paint()..color = Colors.blue.withOpacity(0.15),
        text: atText,
        actualText: atText,
        start: start,

        ///caret can move into special text
        deleteAll: true,
        style: textStyle,
        recognizer: (TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) onTap!(atText);
          }))
        : SpecialTextSpan(
        text: atText,
        actualText: atText,
        start: start,
        style: textStyle,
        recognizer: (TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) onTap!(atText);
          }));
  }
}