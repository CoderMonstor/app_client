import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FileConverter {
  /// 将 XFile 转换为 File
  static File toFile(XFile xFile) {
    return File(xFile.path);
  }

  /// 将 File 转换为 XFile
  static XFile toXFile(File file) {
    return XFile(file.path);
  }
}