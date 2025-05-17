import 'dart:async';


import 'package:flutter/material.dart';


import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../util/toast.dart';
import '../../widget/login_text_widget.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  late Timer _timer;
  late int _countdownTime;

  @override
  void initState() {
    super.initState();
    _countdownTime = 30;
  }

  //输入框控制器
  TextEditingController _emailController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  GlobalKey _formKey =GlobalKey<FormState>();
  late String email;
  late String pwd;
  late String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("重置密码")),
      body: Form(
        key: _formKey, //设置globalKey,用于后面获取FormState
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          children: <Widget>[
            const SizedBox(
              height: 40.0,
            ),
            const SizedBox(
              height: 40.0,
            ),
            buildEmailTextField(_emailController), //邮箱输入框
            buildPwdTextField(_pwdController), //密码输入框
            TextFormField(
              keyboardType: TextInputType.number,
              controller: _codeController,
              decoration: InputDecoration(
                  labelText: "验证码",
                  hintText: "点击右侧获取",
                  icon: const Icon(Icons.security),
                  suffix: GestureDetector(
                    onTap: () async {
                      if (_countdownTime == 30 &&
                          (_formKey.currentState as FormState).validate()) {
                        startCountdownTimer();
                        Toast.popToast("验证码发送中，请稍等");
                        //请求发送验证码
                        email = _emailController.text;
                        var result = await NetRequester.request(Apis.sendEmail(email));
                        if (result == 1) {
                          Toast.popToast("验证码已发送请注意查收");
                        } else {
                          Toast.popToast("请检查网络或反馈错误 ");
                        }
                      }
                    },
                    child: Text(
                      _countdownTime == 30 ? '获取验证码' : '$_countdownTime秒后重新获取',
                      style: TextStyle(
                        color: _countdownTime == 30
                            ? const Color.fromARGB(255, 17, 132, 255)
                            : const Color.fromARGB(255, 183, 184, 195),
                      ),
                    ),
                  )),
            ), //验证码框
            Padding(
              //修改按钮
              padding:
              const EdgeInsets.only(top: 70.0, left: 60.0, right: 40.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("确认修改"),
                onPressed: () async {
                  if ((_formKey.currentState as FormState).validate() &&
                      _emailController.text == email) {
                    pwd = _pwdController.text;
                    code = _codeController.text;
                    var result = await NetRequester.request(Apis.updatePassword(email, pwd, code));
                    switch (result) {
                      case 1:
                        Toast.popToast("修改成功请前往登陆");
                        break;
                      case -1:
                        Toast.popToast("验证码错误");
                        break;
                      case 0:
                        Toast.popToast("该账户不存在请直接注册");
                        break;
                      case -2:
                        Toast.popToast("请先获取验证码");
                        break;
                    }
                  } else {
                    Toast.popToast("与获得验证码的邮箱不符");
                  }
                },
              ),
            ) //修改按钮
          ],
        ),
      ),
    );
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_countdownTime == 0) {
        _timer.cancel();
        if(mounted){
          setState(() {
            _countdownTime = 30;
          });
        }
      }else{
        if(mounted){
          setState(() {
            _countdownTime--;
          });
        }
      }
    });
  } //倒计时实现方法

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  } //释放时取消定时器
}
