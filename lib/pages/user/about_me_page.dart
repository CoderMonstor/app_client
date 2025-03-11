import 'package:client/core/model/user_model.dart';
import 'package:client/pages/setting_page.dart';
import 'package:client/pages/user/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../util/my_icon/my_icon.dart';
import '../fans_page.dart';
import '../follow_page.dart';
import '../post/my_post_page.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> with AutomaticKeepAliveClientMixin{
  // 是否关闭小头像
  late bool _offLittleAvatar;
  // 滚动控制器
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _offLittleAvatar=true;
    var downLock=true;
    var upLock=false;
    _scrollController.addListener(() {
      // 判断滚动位置.如果滚动位置大于70并且downLock为true,则关闭小头像
      if(_scrollController.position.pixels>90&& downLock){
        setState(() {
          _offLittleAvatar=false;
        });
        upLock=true;
        downLock=false;
      }
      // 判断滚动位置.如果滚动位置小于70并且upLock为true,则打开小头像
      if(_scrollController.position.pixels<=90&& upLock){
        setState(() {
          _offLittleAvatar=true;
        });
        upLock=false;
        downLock=true;
      }
    });
    print('');
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        // 透明度
        elevation: 0,
        title: Offstage(
          offstage: _offLittleAvatar,
          child: SizedBox(
            width: ScreenUtil().setWidth(90),
            height: ScreenUtil().setHeight(90),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/head/head1.jpg'),
           ),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
                MyIcons.scan,
                color: Colors.black,
              ),
              onPressed: () async{
                //TODO
              }),
          Container(
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(24)),
            child: IconButton(
              icon: const Icon(
                MyIcons.setting,
                color: Colors.black,
              ),
              onPressed: () {
                //TODO:跳转到设置页面
                Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingPage()));
              },
            ),
          )
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          _buildShowUserInfo(),
          Container(
            height: 800,
          )
        ],
      ),
    );
  }

  Widget _buildShowUserInfo() {
        return Consumer<UserModel>(
          builder: (BuildContext context, model, _) {
           return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Theme.of(context).scaffoldBackgroundColor
                  ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                ),
                height: ScreenUtil().setHeight(200),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.push(context, CupertinoPageRoute(builder: (context) => ProfilePage(userId:model.user.userId)));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: ScreenUtil().setWidth(80),
                                      width: ScreenUtil().setWidth(80),
                                      child: const CircleAvatar(
                                        backgroundImage:AssetImage('assets/images/head/head1.jpg'),
                                        // Global.profile.user?.avatarUrl ==null
                                        //     ? const AssetImage('assets/images/head/head1.jpg')
                                        //     : NetworkImage('${NetConfig.ip}/images/${Global.profile.user!.avatarUrl}'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(30),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "用户",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScreenUtil().setSp(30),
                                            ),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(15),
                                          ),
                                          Text(
                                            "这人很懒，什么也没写",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: ScreenUtil().setSp(16)),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(
                                      MyIcons.qr_code,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      //TODO
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20))),
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                        child: SizedBox(
                          height: ScreenUtil().setHeight(80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // _buildShowNum(model.user.postNum==null?'0':model.user.postNum.toString(),'动态',MyPostPage()),
                              _buildShowNum(model.user.postNum==null ? '0' : model.user.postNum.toString() , '动态', const MyPostPage()),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300,width: 0.5),
                                ),
                              ),
                              _buildShowNum(model.user.followNum==null?'0':model.user.followNum.toString(),'关注',const FollowPage()),
                              // _buildShowNum(model.user.followNum.toString() ?? '0', '关注', const FollowPage()),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300,width: 0.5)
                                ),
                              ),
                              _buildShowNum(model.user.fanNum==null?'0':model.user.fanNum.toString(),'粉丝',const FansPage()),
                              // _buildShowNum(model.user.fanNum.toString() ?? '0', '粉丝', const FansPage()),
                            ],
                          ),
                        ),
                      )
                    ]
                )
            );
          },
        );
  }
  Widget _buildShowNum(String num, String label,Widget page) {
    return TextButton(
      onPressed: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => page));
      },
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(num.length < 4 ? num : '999+',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(25),
                    fontWeight: FontWeight.w600)
            ),
            Text(
                label,
                // style: TextStyle(fontSize: ScreenUtil().setSp(36), color: Colors.grey)
            ),
          ],
        ),
      ),
    );
  }
  @override
  bool get wantKeepAlive =>true;
}

