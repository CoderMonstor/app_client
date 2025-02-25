import 'package:flutter/material.dart';

class ThemeModel with ChangeNotifier {
  // 用于控制主题的布尔值，例如是否为暗色主题
  bool isDark;

  // 主题的主色调
  Color themeColor;

  // 初始化主题模型
  ThemeModel({this.isDark = false, this.themeColor = Colors.blue});

  // 切换主题的方法，当调用时会通知监听器主题已更改
  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  bool get isDarkTheme => isDark;

  Color get theme => themeColor;

  void changeTheme(Color newTheme) {
    themeColor = newTheme;
    notifyListeners();
  }
}
