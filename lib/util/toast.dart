/*
这个工具类主要是对oktoast进行封装
* */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:oktoast/oktoast.dart';

class Toast {
  //提供一个弹出toast的方法在okToast的方法基础上设置了一些基本参数，使用时只需传入@param[msg]
  //弹出一个toast，位置在屏幕中间，默认背景色为黑色，文字为白色，文字间距为40，文字高度为5
  static popToast(String msg, [ToastPosition position = ToastPosition.center]) {
    //这里调用的是okToast库的方法
    showToast(
      msg,
      dismissOtherToast: true,
      backgroundColor: Colors.black87,
      textPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      position: position,
    );
  }

  //这是一个弹出加载中的toast，默认背景色为黑色，文字为白色，文字间距为40，文字高度为5
  //传入的@param[msg]是可选参数，默认为空，如果传入了@param[msg]，则显示在toast中，否则不显示
  static popLoading([String msg = '', int sec = 10]) {
    showToastWidget(
      Material(
        color: Colors.black54,
        child: SizedBox(
          width: 1080.w,
          height: 1920.h,
          child: Center(
              child: Container(
                width: ScreenUtil().setWidth(300),
                height: ScreenUtil().setWidth(300),
                decoration: BoxDecoration(
                  color: const Color(0xddffffff),
                  borderRadius: BorderRadius.circular(ScreenUtil().setHeight(21)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(30)),
                      //SpinKitRing是一个圆形的loading动画
                      child: SpinKitRing(
                        color: Colors.blue,
                        lineWidth: 3,
                        size: ScreenUtil().setWidth(120),
                      ),
                    ),
                    // Offstage是一个隐藏组件，如果@param[msg]为空，则隐藏，否则显示
                    Offstage(
                      offstage: msg == '',
                      child: Text(msg),
                    )
                  ],
                ),
              )),
        ),
      ),
      position: ToastPosition.center,
      duration: Duration(seconds: sec),
      // 点击toast可以关闭
      handleTouch: true,
    );
  }
}
