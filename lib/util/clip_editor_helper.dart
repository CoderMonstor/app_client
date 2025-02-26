import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart';

Future<List<int>> cropImageDataWithNativeLibrary({ExtendedImageEditorState? state}) async {
  if (state == null) {
    throw ArgumentError('state cannot be null');
  }

  final cropRect = state.getCropRect();
  final action = state.editAction;

  // 获取旋转角度和翻转状态
  final rotateAngle = action?.rotateRadians; // 使用 rotateRadians 属性
  final flipHorizontal = action?.flipX; // 使用 flipX 属性
  final flipVertical = action?.flipY; // 使用 flipY 属性
  final img = state.rawImageData;

  ImageEditorOption option = ImageEditorOption();

  if (action != null && action.needCrop) {
    option.addOption(ClipOption.fromRect(cropRect!));
  }

  if (action != null && action.needFlip) {
    option.addOption(FlipOption(horizontal: flipHorizontal!, vertical: flipVertical!));
  }


  if (rotateAngle != null && rotateAngle != 0) {
    // 将 double 类型的旋转角度转换为 int 类型
    final intRotateAngle = (rotateAngle * (180 / pi)).round(); // 将弧度转换为角度并取整
    option.addOption(RotateOption(intRotateAngle));
  }

  // final start = DateTime.now();
  final result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );

  // 转换Uint8List为List<int>
  return result!.toList();
}
