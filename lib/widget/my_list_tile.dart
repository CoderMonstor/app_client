import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 自定义 ListTile 小部件，支持自定义间距和布局。
/// 支持以下 三种布局方式
/// 1.leading
/// 2.center
/// 3.trailing
/// 4.leading and center between
/// 5.center and trailing between
///
class MyListTile extends StatefulWidget {
  /// 左侧间距
  final double? left;

  /// 右侧间距
  final double? right;

  /// 顶部间距
  final double? top;

  /// 底部间距
  final double? bottom;

  /// 领先部件（leading）和中心部件（center）之间的间距
  final double? betweenLeadingAndCenter;

  /// 中心部件（center）和尾随部件（trailing）之间的间距
  final double? betweenCenterAndTrailing;

  /// 领先部件（leading）
  final Widget? leading;

  /// 中心部件（center）
  final Widget? center;

  /// 尾随部件（trailing）
  final Widget? trailing;

  /// 单击事件回调
  final GestureTapCallback? onTap;

  /// 双击事件回调
  final GestureDoubleTapCallback? onDoubleTap;

  /// 是否使用 ScreenUtil 进行尺寸转换
  final bool? useScreenUtil;

  /// 中心部件的交叉轴对齐方式
  final CrossAxisAlignment? crossAxis;

  /// 构造函数
  const MyListTile({
    super.key,
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.betweenLeadingAndCenter,
    this.betweenCenterAndTrailing,
    this.leading,
    this.center,
    this.trailing,
    this.onTap,
    this.onDoubleTap,
    this.useScreenUtil,
    this.crossAxis,
  });

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    //创建一个可点击的容器，并添加了双击事件处理
    return InkWell(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap, // 添加双击事件处理
      child: Container(
        padding: EdgeInsets.only(
          top: (widget.useScreenUtil ?? false)
              ? ScreenUtil().setHeight(widget.top ?? 0) // 使用 ScreenUtil 进行高度转换
              : widget.top ?? 0,
          bottom: (widget.useScreenUtil ?? false)
              ? ScreenUtil()
              .setHeight(widget.bottom ?? 0) // 使用 ScreenUtil 进行高度转换
              : widget.bottom ?? 0,
          left: (widget.useScreenUtil ?? false)
              ? ScreenUtil().setWidth(widget.left ?? 0) // 使用 ScreenUtil 进行宽度转换
              : widget.left ?? 0,
          right: (widget.useScreenUtil ?? false)
              ? ScreenUtil().setWidth(widget.right ?? 0) // 使用 ScreenUtil 进行宽度转换
              : widget.right ?? 0,
        ),
        child: Row(
          //垂直方向：居中对齐
          crossAxisAlignment: CrossAxisAlignment.center,
          //水平方向：两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              //垂直方向：居中对齐
              crossAxisAlignment: widget.crossAxis ?? CrossAxisAlignment.center,
              //水平方向：两端对齐
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //如果leading不为空，则创建一个容器，并添加leading
                if (widget.leading != null) Container(child: widget.leading),
                //如果betweenLeadingAndCenter不为空，则创建一个容器，并添加betweenLeadingAndCenter
                if (widget.betweenLeadingAndCenter != null)
                  SizedBox(
                    width: (widget.useScreenUtil ?? false)
                        ? ScreenUtil().setWidth(
                        widget.betweenLeadingAndCenter ?? 0) // 使用 ScreenUtil 进行宽度转换
                        : widget.betweenLeadingAndCenter ?? 0,
                  ),
                //如果center不为空，则创建一个容器，并添加center
                if (widget.center != null) Container(child: widget.center),
              ],
            ),
            //如果trailing不为空，则创建一个容器，并添加trailing
            if (widget.trailing != null) Container(child: widget.trailing),
          ],
        ),
      ),
    );
  }
}
