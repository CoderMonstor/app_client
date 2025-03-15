import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppbar {
  static PreferredSizeWidget buildNormalAppbar(BuildContext context, bool backIcon, bool msgIcon, TextEditingController? textController,PreferredSizeWidget? bottom) {
    return AppBar(
      automaticallyImplyLeading: backIcon,
      title: Container(
        margin: EdgeInsets.only(
          top: ScreenUtil().setHeight(16),
          bottom: ScreenUtil().setHeight(16), // 增加底部外边距
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: TextField(
          controller: textController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '|   搜索',
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: ScreenUtil().setSp(18),
            ),
            suffixIcon: !msgIcon ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //  清空搜索框内容
                textController?.clear();
              },
            ) : null,
            prefixIcon: const Icon(Icons.search),
            prefixIconConstraints: BoxConstraints(
              minWidth: ScreenUtil().setWidth(50), // 设置前缀图标的最小宽度
            ),
          ),
          readOnly: msgIcon,
          showCursor: !msgIcon,
          onSubmitted: (value) {
            _handleSearch(context, value);
          },
          onTap: () {
            if (msgIcon) {
              Navigator.pushNamed(context, '/search');
            }
          },
        ),
      ),
      elevation: 1,
      actions: msgIcon ? <Widget>[
        Container(
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(24)),
          child: IconButton(
            icon: const Icon(
              Icons.messenger_outline,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/message');
              // Navigator.push(context, CupertinoPageRoute(builder: (context)=>const MessageListPage()));
            },
          ),
        ),
      ] : <Widget>[],
      // 底部占位，避免appbar被底部导航栏遮挡
      bottom: bottom??PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(4)),
        child: Container(),
      ),
    );
  }

  // 简单appbar
  static PreferredSizeWidget simpleAppbar(String title) {
    return AppBar(
      title: Text(title),
      elevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4), // 修改为正值
        child: Container(),
      ),
    );
  }

  // 处理搜索操作
  static void _handleSearch(BuildContext context, String query) {
    if (query.isNotEmpty) {
      // 执行搜索操作
      print('Searching for: $query');

      // 隐藏键盘
      FocusScope.of(context).unfocus();
    }
  }
}
