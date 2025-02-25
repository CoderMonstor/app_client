import 'package:client/core/model/user.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  // 公共变量，用于存储当前的用户数据
  User user;

  // 构造函数，初始化用户数据为一个空的 User 对象
  UserModel() : user = User.none();

  // 更新用户数据的方法
  void updateUser(User newUser) {
    user = newUser;
    // 通知监听器用户数据已经更新
    notifyListeners();
  }

  // 假设有一个方法用于检查用户是否登录
  bool isUserLoggedIn() {
    return user.userId != 0;
  }

  // 获取用户ID的方法
  int? getUserId() {
    return user.userId;
  }

  // 获取用户名的方法
  String? getUsername() {
    return user.username;
  }

  // 获取用户邮箱的方法
  String? getEmail() {
    return user.email;
  }

  // 获取用户头像地址的方法
  String? getAvatarUrl() {
    return user.avatarUrl;
  }

  // 获取用户简介的方法
  String? getBio() {
    return user.bio;
  }

  // 获取用户生日的方法
  String? getBirthDay() {
    return user.birthDay;
  }

  // 获取用户性别的方法
  int? getGender() {
    return user.gender;
  }

  // 获取用户所在城市的方法
  String? getCity() {
    return user.city;
  }

  // 获取用户背景图片地址的方法
  String? getBackImgUrl() {
    return user.backImgUrl;
  }

  // 获取用户帖子数量的方法
  int? getPostNum() {
    return user.postNum;
  }

  // 获取用户粉丝数量的方法
  int? getFanNum() {
    return user.fanNum;
  }

  // 获取用户关注数量的方法
  int? getFollowNum() {
    return user.followNum;
  }

  // 获取用户是否关注的状态的方法
  int? getIsFollow() {
    return user.isFollow;
  }
}
