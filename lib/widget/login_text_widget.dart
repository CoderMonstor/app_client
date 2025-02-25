import 'package:flutter/material.dart';

TextFormField buildEmailTextField(TextEditingController a) {
  return TextFormField(
    keyboardType: TextInputType.emailAddress,
    controller: a,
    decoration: const InputDecoration(
        labelText: "账号", hintText: "请输入您的邮箱地址", icon: Icon(Icons.person)),
    // 校验用户名
    validator: (String? value) {
      if (value == null || value.isEmpty) {
        return '请输入邮箱地址';
      }
      var emailReg = RegExp(
          r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
      if (!emailReg.hasMatch(value)) {
        return '请输入正确的邮箱地址';
      }
      return null; // 表示校验通过
    },
  );
}

TextFormField buildPwdTextField(TextEditingController a) {
  return TextFormField(
    controller: a,
    decoration: const InputDecoration(
      labelText: "密码",
      hintText: "登陆密码最短6位",
      icon: Icon(Icons.lock),
    ),
    obscureText: true,
    // 校验密码
    validator: (String? v) {
      if (v == null || v.trim().isEmpty) {
        return '请输入密码';
      }
      return v.trim().length > 5 ? null : "登录密码不能小于6位";
    },
  );
}
