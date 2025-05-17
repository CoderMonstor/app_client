import 'dart:async';


import 'package:flutter/material.dart';

import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../util/toast.dart';
import '../../widget/login_text_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Timer? _timer;
  late int _countdownTime;

  @override
  void initState() {
    super.initState();
    _countdownTime = 30;
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _codeController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          children: [
            const SizedBox(height: 40),
            buildEmailTextField(_emailController),
            buildPwdTextField(_passwordController),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: "验证码",
                      icon: Icon(Icons.security),
                    ),
                    validator: (v) {
                      if (v!.trim().length < 4) {
                        return '验证码不能少于4位';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextButton(
                      onPressed: () async {
                        if (_emailController.text.trim().isNotEmpty) {
                          startCountdownTimer(); //点击后开始倒计时
                          Toast.popToast("验证码发送中，请稍等");
                          //请求发送验证码
                          _email = _emailController.text;
                          var result =
                          await NetRequester.request(Apis.sendEmail(_email));
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
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 60, right: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50), // 设置按钮的最小宽度和高度
                ),
                child: const Text("注册"),
                onPressed: () async {
                  final formState = _formKey.currentState;
                  if (formState != null && formState.validate()) {
                    // 表单整体验证通过后再比较邮箱一致性
                    if (_emailController.text == _email) {
                      _password = _passwordController.text;
                      _code = _codeController.text;

                      var result = await NetRequester.request(Apis.addUser(_email, _password, _code));
                      if (result != null) {
                        Toast.popToast(result['msg']);
                      }
                    } else {
                      Toast.popToast("当前邮箱与获取验证码时不一致");
                    }
                  }
                  // 如果验证不通过，Form会自动显示对应字段的错误提示，不需要额外Toast
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_countdownTime == 0) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _countdownTime = 30;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _countdownTime--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}
