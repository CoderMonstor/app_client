import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart';

Future<List<int>> cropImageDataWithNativeLibrary(ImageEditorController imageEditorController) async {
  final EditActionDetails action = imageEditorController.editActionDetails!;

  final img = imageEditorController.state!.rawImageData;

  final ImageEditorOption option = ImageEditorOption();

  if (action.hasRotateDegrees) {
    final int rotateDegrees = action.rotateDegrees.toInt();
    option.addOption(RotateOption(rotateDegrees));
  }
  if (action.flipY) {
    option.addOption(const FlipOption(horizontal: true, vertical: false));
  }

  if (action.needCrop) {
    Rect cropRect = imageEditorController.getCropRect()!;
    if (imageEditorController.state!.widget.extendedImageState.imageProvider
    is ExtendedResizeImage) {
      final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(img);
      final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);

      final double widthRatio =
          descriptor.width / imageEditorController.state!.image!.width;
      final double heightRatio =
          descriptor.height / imageEditorController.state!.image!.height;
      cropRect = Rect.fromLTRB(
        cropRect.left * widthRatio,
        cropRect.top * heightRatio,
        cropRect.right * widthRatio,
        cropRect.bottom * heightRatio,
      );
    }
    option.addOption(ClipOption.fromRect(cropRect));
  }

  final result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );


  // 转换Uint8List为List<int>
  return result!.toList();
}
