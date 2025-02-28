import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart';

Future<List<int>?> cropImageDataWithNativeLibrary(ExtendedImageEditorState? state) async {
  print("native library start cropping");

  // 1. 添加全局空检查
  if (state == null) {
    print("State is null, abort cropping");
    return null;
  }

  // 2. 获取可能为空的属性时添加安全访问
  final cropRect = state.getCropRect();
  final action = state.editAction;

  // 3. 关键属性空检查
  if (action == null) {
    print("Edit action is null");
    return null;
  }

  // 4. 使用安全访问符处理可能为空的属性
  final rotateAngle = action.rotateRadians.toInt();
  final flipHorizontal = action.flipY;
  final flipVertical = action.flipY;
  final img = state.rawImageData;

  final ImageEditorOption option = ImageEditorOption();

  // 6. 条件判断添加选项
  if (action.needCrop) {
    if (cropRect != null) {
      option.addOption(ClipOption.fromRect(cropRect)); // 现在cropRect已确认非空
    } else {
      print("Need crop but cropRect is null");
      return null;
    }
  }

  if (action.needFlip) {
    option.addOption(
      FlipOption(
        horizontal: flipHorizontal,
        vertical: flipVertical,
      ),
    );
  }

  if (action.hasRotateDegrees) {
    option.addOption(RotateOption(action.rotateDegrees.toInt())); // 将 double 转换为 int
  }

  final start = DateTime.now();
  try {
    final result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    print("${DateTime.now().difference(start)} ：total time");
    return result?.toList();
  } catch (e) {
    print("Image editing failed: $e");
    return null;
  }
}