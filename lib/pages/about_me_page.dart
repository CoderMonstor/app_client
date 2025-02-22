import 'package:client/pages/setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../util/my_icon/my_icon.dart';

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
      if(_scrollController.position.pixels>70&& downLock){
        setState(() {
          _offLittleAvatar=false;
        });
        upLock=true;
        downLock=false;
      }
      // 判断滚动位置.如果滚动位置小于70并且upLock为true,则打开小头像
      if(_scrollController.position.pixels<=70&& upLock){
        setState(() {
          _offLittleAvatar=true;
        });
        upLock=false;
        downLock=true;
      }
    });

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
                //rScanCameras= await availableRScanCameras();
                // Navigator.push(context,
                // CupertinoPageRoute(builder: (context) => RScanCameraDialog()));
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
          ),
        ],
      ),
    );
  }

  Widget _buildShowUserInfo() {
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
                children: [
                  Container(
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
                                  backgroundImage: AssetImage("assets/images/head/head1.jpg"),
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
                            // const IconButton(
                            //   icon: Icon(
                            //     MyIcons.right,
                            //     color: Colors.black,
                            //   ),
                            //   onPressed: null,
                            // ),
                          ],
                        ),
                      ],
                    ),

                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20))),
                    margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text("动态"),
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300,width: 0.5),
                            ),
                          ),
                          const Text("关注"),
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300,width: 0.5)
                            ),
                          ),
                          const Text("粉丝"),
                        ],
                      ),
                    ),
                  )
                ]
            )
        );
  }

  @override
  bool get wantKeepAlive =>true;
}

