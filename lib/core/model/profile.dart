/*
这是一个用户信息类，用于存储用户信息，包括用户名、密码、头像、搜索历史等。
* */

import 'package:client/core/model/user.dart';

class Profile {
  User? user;
  List<String>? searchList;
  int? theme;
  bool? isDark;

  Profile({
    this.user,
    this.searchList, // 不使用 const []
    this.theme,
    this.isDark,
  });

  // 确保从 JSON 解析时转换成普通可变 List
  Profile.fromJson(Map<String, dynamic> json)
      : user = json['user'] != null ? User.fromJson(json['user']) : User(),
        searchList = json['searchList'] != null ? List<String>.from(json['searchList']) : [],
        theme = json['theme'] ?? 0,
        isDark = json['isDark'] ?? false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user'] = user!.toJson();
    data['searchList'] = searchList;
    data['theme'] = theme;
    data['isDark'] = isDark;
    return data;
  }
}

