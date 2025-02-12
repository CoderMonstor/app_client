import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MyAppbar{

  static PreferredSizeWidget build(BuildContext context,Widget? title) {
    return AppBar(
      //automaticallyImplyLeading：显示默认的返回按钮
      automaticallyImplyLeading: false,
      title: title,
      // 设置应用栏的阴影高度（即阴影的强度）为 1。
      // 较小的值会使阴影较轻，较大的值会使阴影更明显
      elevation: 1,
      // 左侧按钮
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          if (kDebugMode) {
            print("=======================> on clicked");
          }
        },
      ),

      // 右侧按钮
      actions: <Widget>[
        Container(
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(24)),
          child: IconButton(
            icon: const Icon(
              Icons.search,
              // color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
              // Navigator.push(context, CupertinoPageRoute(builder: (context) => const SearchPage()));
            },
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(-8),
        child: Container(),
      ),
    );
  }
//  简单appbar
  static PreferredSizeWidget simpleAppbar(String title){
    return AppBar(
      title: Text(title),
      elevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(-8),
        child: Container(),
      ),
    );
  }


  }

