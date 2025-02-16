/*
这个界面主要用于构建指示器
@[param]:
context:上下文
status:当前状态
listRepository:当前列表数据源
isSliver:是否可以滑动
 */

import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';


Widget buildIndicator(BuildContext context, IndicatorStatus status, LoadingMoreBase listRepository, {bool isSliver = false}) {
  // 根据状态返回不同的指示器
  Widget widget;
  switch (status) {
    // 初始状态,如果没有数据，则显示空页面
    case IndicatorStatus.none:
      widget = Container(height: 0.0);
      break;
      // 加载更多中
    case IndicatorStatus.loadingMoreBusying:
      widget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 5.0),
            height: 15.0,
            width: 15.0,
            child: getIndicator(context),
          ),
          const Text("正在加载...")
        ],
      );
      widget = _setbackground(context, false, widget, 35.0);
      break;
      // 加载更多完成
    case IndicatorStatus.fullScreenBusying:
      widget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 0.0),
            height: 30.0,
            width: 30.0,
            child: getIndicator(context),
          ),
        ],
      );
      widget = _setbackground(context, true, widget, double.infinity);
      if (isSliver) {
        widget = SliverFillRemaining(
          child: widget,
        );
      } else {
        widget = Center(child: widget);
      }
      break;
      // 加载更多失败
    case IndicatorStatus.error:
      widget = const Text(
        "好像出现了问题呢？",
      );
      widget = _setbackground(context, false, widget, 35.0);

      widget = GestureDetector(
        onTap: () {
          listRepository.errorRefresh();
        },
        child: widget,
      );

      break;
      // 全屏加载更多失败
    case IndicatorStatus.fullScreenError:
      widget = const Text(
        "好像出现了问题呢？",
      );
      widget = _setbackground(context, true, widget, double.infinity);
      widget = GestureDetector(
        onTap: () {
          listRepository.errorRefresh();
        },
        child: widget,
      );
      if (isSliver) {
        widget = SliverFillRemaining(
          child: widget,
        );
      } else {
        widget = Center(child: widget);
      }
      break;
      // 没有更多了
    case IndicatorStatus.noMoreLoad:
      widget = const Text("没有更多了");
      widget = _setbackground(context, false, widget, 50.0);
      break;
      // 空页面
    case IndicatorStatus.empty:
      widget = Text(
        "什么也没有找到(つд⊂)", style: TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(46)),
      );
      widget = _setbackground(context, true, widget, double.infinity);
      widget = GestureDetector(
        onTap: () {
          listRepository.errorRefresh();
        },
        child: widget,
      );
      if (isSliver) {
        widget = SliverToBoxAdapter(
          child: widget,
        );
      } else {
        widget = Center(child: widget);
      }
      break;
  }
  return widget;
}
// 设置背景颜色和padding
Widget _setbackground(BuildContext context,bool full, Widget widget, double height) {
  widget = Container(
      width: double.infinity,
      height: height,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: widget);
  return widget;
}
// 获取指示器
Widget getIndicator(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS
      ? const CupertinoActivityIndicator(
    animating: true,
    radius: 16.0,
  )
      : CircularProgressIndicator(
    strokeWidth: 2.0,
    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
  );
}
