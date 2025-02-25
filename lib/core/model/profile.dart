/*
这是一个用户信息类，用于存储用户信息，包括用户名、密码、头像、搜索历史等。
* */


import 'package:client/core/model/user.dart';

class Profile {
  User? user;
  List<String>? searchList;
  int? theme;
  bool? isDark;
  String? ip;

  Profile({
    this.user,
    this.searchList,
    this.theme,
    this.isDark,
    this.ip,
  });

  ///此时创建一个空的 Profile 对象，
  ///其中 user 属性为 User.none()，表示用户信息为空，
  ///searchList 属性为空列表，
  ///theme 属性为 0，
  ///isDark 属性为 false，
  ///ip 属性为空字符串。
  Profile.none()
      : user = User.none(),
        searchList = [],
        theme = 0,
        isDark = false,
        ip = '';

  ///从 json 数据中创建 Profile 对象
  Profile.fromJson(Map<String, dynamic> json)
      : user = json['user'] != null ? User.fromJson(json['user']) : User(),
        searchList = json['searchList'].cast<String>()??[],
        theme = json['theme'] ?? 0,
        isDark = json['isDark'] ?? false,
        ip = json['ip'] ?? '';



  ///将 Profile 对象转换为 json 数据
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user'] = user!.toJson(); // 直接添加 user.toJson()
    data['searchList'] = searchList;
    data['theme'] = theme;
    data['isDark'] = isDark;
    data['ip'] = ip;
    return data;
  }

}
