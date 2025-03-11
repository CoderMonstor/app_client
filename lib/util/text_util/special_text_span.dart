import 'package:client/util/text_util/view_image_text.dart';
import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/material.dart';

import 'at_text.dart';
import 'emoji_text.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  /// whether show background for @somebody
  final bool showAtBackground;
  final BuildContext context;
  MySpecialTextSpanBuilder({required this.context,this.showAtBackground = false});

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    var textSpan = super.build(data, textStyle: textStyle, onTap: onTap);
    return textSpan;
  }

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, int? index}) {
    if (flag == "") return null;

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, AtText.flag)) {
      // 检查并处理可能导致 null 的情况
      if (textStyle == null || onTap == null) {
        return null; // 或者返回一个默认的 SpecialText 实例
      }
      return AtText(
        textStyle,
        onTap,
        start: index! - (AtText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    } else if (isStart(flag, EmojiText.flag)) {
      if (textStyle == null) {
        return null; // 或者返回一个默认的 SpecialText 实例
      }
      return EmojiText(textStyle, start: index! - (EmojiText.flag.length - 1));
    } else if (isStart(flag, ViewImgText.flag)) {
      if (textStyle == null || onTap == null) {
        return null; // 或者返回一个默认的 SpecialText 实例
      }
      return ViewImgText(
          textStyle,
          onTap,
          color: Theme.of(context).primaryColor,
          start: index! - (ViewImgText.flag.length - 1)
      );
    }
    return null;
  }
}