import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/my_icon/my_icon.dart';
class SettingTail extends StatefulWidget {
  final String? title;
  final Widget? page;
  const SettingTail({super.key, this.title,  this.page});

  @override
  State<SettingTail> createState() => _SettingTailState();
}

class _SettingTailState extends State<SettingTail> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => widget.page!));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: ScreenUtil().setHeight(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                widget.title!,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(120)),
              Icon(
                MyIcons.right,
                size: ScreenUtil().setWidth(20),
                color: Colors.grey,
              ),
            ]
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
          // 分割线
          Divider(indent: ScreenUtil().setWidth(40),endIndent: ScreenUtil().setWidth(50),),
        ],
      ),
    );
  }
}
