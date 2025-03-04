import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import '../../core/global.dart';
import '../../core/model/user.dart';
import '../../core/model/user_model.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../util/toast.dart';
import '../../widget/login_text_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();
  String? email;
  String? pwd;
  bool _isObscure = true;
  Color? _eyeColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            children: <Widget>[
              const SizedBox(
                height: kToolbarHeight + 20.0,
              ), //顶部填充
              const Image(
                image: AssetImage("assets/images/orange.jpg"),
                width: 280.0,
                height: 280.0,
              ), //logo
              const SizedBox(height: 20.0),
              buildEmailTextField(_nameController), //账号输入框
              TextFormField(
                controller: _pwdController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                    labelText: "密码",
                    hintText: "密码不能少于6位",
                    icon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _eyeColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                          _eyeColor = _isObscure
                              ? Colors.grey
                              : Theme.of(context).primaryColor;
                        });
                      },
                    )),
                //校验密码
                validator: (v) {
                  return v!.trim().length > 5 ? null : "密码不能少于6位";
                },
              ), //密码框
              const SizedBox(
                height: 8.0,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                  ),
                  child: const Text('忘记密码？'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/forget');
                  },
                ),
              ), //忘记密码
              Padding(
                padding: const EdgeInsets.only(top: 35.0, left: 60.0, right: 40.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(10.0)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text("登录"),
                  onPressed: () async {
                    if ((_formKey.currentState as FormState).validate()) {
                      email = _nameController.text;
                      pwd = _pwdController.text;
                      var result = await NetRequester.request(Apis.login(email!, pwd!));
                      //根据服务器返回结果进行提示
                      if (result["code"] == "0") {
                        Toast.popToast("账户或密码输入错误，请重试");
                      } else {
                        Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
                        // print('==================================='+result["data"]);
                        User user = User.fromJson(result["data"]);
                        print(user);
                        Global.profile.user = user;
                        Global.saveProfile();
                        // 使用 Provider 获取 UserModel 实例并调用 updateUser 方法
                        // Provider.of<UserModel>(context, listen: false).updateUser(user);
                        print(Global.profile.user);
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('没有账号？'),
                    GestureDetector(
                      child: const Text(
                        '点击注册',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  ],
                ),
              ), //注册跳转
            ],
          ),
        ),
      ),
    );
  }
}
