// 全局变量
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/profile.dart';
final _themes = [
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
  Colors.pink,
];

class Global {

  static late SharedPreferences _prefs;
  static Profile profile = Profile();
  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;


  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    // 初始化加载profile
    var profile = _prefs.getString("profile");
    if (profile != null) {
      try {
        Global.profile = Profile.fromJson(jsonDecode(profile));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  static void saveProfile() {
    _prefs.setString("profile", jsonEncode(profile.toJson()));
  }

}
