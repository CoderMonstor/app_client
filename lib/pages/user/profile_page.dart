import 'package:client/pages/activity/common_activity.dart';
import 'package:client/pages/post/common_post.dart';
import 'package:client/pages/resale/common_goods_page.dart';
import 'package:client/pages/user/qr_page.dart';
import 'package:client/util/my_icon/my_app_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';

import '../../core/global.dart';
import '../../core/list_repository/activity_repo.dart';
import '../../core/list_repository/goods_repo.dart';
import '../../core/list_repository/post_repo.dart';
import '../../core/model/activity.dart';
import '../../core/model/post.dart';
import '../../core/model/theme_model.dart';
import '../../core/model/user.dart';
import '../../core/model/user_model.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net.dart';
import '../../core/net/net_request.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/toast.dart';
import '../../widget/build_indicator.dart';
import '../../widget/flexible_detail_bar.dart';
import '../../widget/my_card/activity_card.dart';
import '../../widget/my_card/post_card.dart';
import '../../widget/my_list_tile.dart';
import '../mobile_scan_dialog.dart';
import 'setting_page.dart';
import '../chat/chat_page.dart';


class ProfilePage extends StatefulWidget {
  final int? userId;
  final String? username;
  const ProfilePage({super.key,this.userId, this.username});
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late User _user;
  late TabController _tabController;
  late PageController _pageController;
  late bool _offLittleAvatar;
  late ScrollController _scrollController;
  var _future;
  late PostRepository _postRepository;
  final _localUser=Global.profile.user;

  @override
  void initState() {
    _future = _getUser();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _scrollController = ScrollController();
    _postRepository =  PostRepository(_localUser!.userId!, 1);
    _offLittleAvatar = true;
    var downLock = true;
    var upLock = false;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 140 && downLock) {
        setState(() {
          _offLittleAvatar = false;
        });
        upLock = true;
        downLock = false;
      }
      if (_scrollController.position.pixels < 140 && upLock) {
        setState(() {
          _offLittleAvatar = true;
        });
        upLock = false;
        downLock = true;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _postRepository.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
          future: _future,
          builder: (context, snap){
            if (snap.connectionState == ConnectionState.done) {
              if (snap.hasError) {
                return Center(
                  child: Text('加载失败，请重试',style: TextStyle(fontSize: ScreenUtil().setSp(24)),),
                );
              }else{
                return _buildScaffoldBody();
              }
            }else{
              return Center(
                child: SpinKitRing(
                  lineWidth: 3,
                  color: Theme.of(context).primaryColor,
                ),
              );
            }
          }
      ),
    );
  }

  Widget _buildScaffoldBody() {
    //从当前上下文中获取状态栏的高度
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //固定头部的高度
    var pinnedHeaderHeight = statusBarHeight + kToolbarHeight + 35;
    return extended.ExtendedNestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: _headerSliverBuilder,
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      body: PageView(
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        controller: _pageController,
        children: <Widget>[
          CommonPostPage(type: 1,userId: _user.userId ?? _localUser!.userId),
          // LoadingMoreList(
          //   ListConfig<Post>(
          //     itemBuilder: (BuildContext context, Post item, int index){
          //       // return PostCard(post: item,list: _postRepository,index: index);
          //       return PostCard(post: item,index: index);
          //     },
          //     sourceList: _postRepository,
          //     indicatorBuilder: _buildIndicator,
          //   ),
          // ),
          CommonGoodsPage(type: 3,userId: _user.userId ?? _localUser!.userId,),
          // LoadingMoreList(
          //   ListConfig<Goods>(
          //     itemBuilder: (BuildContext context, Goods item, int index){
          //       return MyGoodsCard(goods: item);
          //     },
          //     sourceList: _goodsRepository,
          //     indicatorBuilder: _buildIndicator,
          //     padding: EdgeInsets.only(
          //         top:ScreenUtil().setWidth(20),
          //         left: ScreenUtil().setWidth(20),
          //         right: ScreenUtil().setWidth(20)
          //     ),
          //   ),
          // ),
          CommonActivity(type: 2,userId: _user.userId ?? _localUser!.userId,)
          // LoadingMoreList(
          //   ListConfig<Activity>(
          //     itemBuilder: (BuildContext context, Activity item, int index){
          //       // return PostCard(post: item,list: _postRepository,index: index);
          //       return ActivityCard(activity: item);
          //     },
          //     sourceList: _activityRepository,
          //     indicatorBuilder: _buildIndicator,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _postRepository);
  }
  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[_sliverAppBar(context)];
  }

  Widget _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      //标题栏是否固定
      pinned: true,
      //显示控制组件，可以控制子组件的显示与隐藏
      title: Offstage(
        offstage: _offLittleAvatar,
        child: Text(_user.username!),
      ),
      actions: _localUser!.userId == _user.userId?[
        TextButton(
          child: const Icon(MyIcons.scan, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => const MobileScanCameraDialog()));
          },
        ),
        Container(
          margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
          child: TextButton(
            child: const Icon(MyIcons.setting, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => const SettingPage()));
            },
          ),
        ),
      ]:null,
      expandedHeight: 350,
      flexibleSpace: FlexibleDetailBar(
        background: FlexShadowBackground(
            child:Image(
              image:_user.backImgUrl == null||_user.backImgUrl!.isEmpty ?const AssetImage("assets/images/back.jpg") :NetworkImage('${NetConfig.ip}/images/${_user.backImgUrl}'),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,)),
        content: Container(
          padding: EdgeInsets.only(
            // top: ScreenUtil().setWidth(90),
              left: ScreenUtil().setWidth(24),
              right: ScreenUtil().setWidth(24)),
          decoration: const BoxDecoration(color: Colors.black26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 8,child: Container(),),
              MyListTile(
                leading:  SizedBox(
                    height: 90,
                    width: 90,
                    child: CircleAvatar(
                        backgroundImage:_user.avatarUrl == null ||_user.backImgUrl!.isEmpty? const AssetImage("assets/images/head/head1.jpg") : NetworkImage('${NetConfig.ip}/images/${_user.avatarUrl}')
                    )),
                trailing: Row(
                  children: <Widget>[
                    Offstage(
                      offstage: _localUser.userId == _user.userId,
                      child: TextButton(
                          style: ButtonStyle(
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0))),
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.grey; // 按下时的颜色
                                  }
                                  return _user.isFollow == 1
                                      ? Colors.white54
                                      : Theme.of(context).primaryColor;
                                }),
                          ),
                          onPressed: () async {
                            var fanId = Global.profile.user!.userId;
                            var res = await NetRequester.request(
                                _user.isFollow == 0
                                    ? Apis.followAUser(fanId!, _user.userId!)
                                    : Apis.cancelFollowAUser(fanId!, _user.userId!));
                            if (res['code'] == '1') {
                              setState(() {
                                _user.isFollow = _user.isFollow == 1 ? 0 : 1;
                              });
                              _user.isFollow == 1
                                  ? Global.profile.user!.followNum! +  1
                                  : Global.profile.user!.followNum! -  1;
                                final userModel = Provider.of<UserModel>(context, listen: false);
                                userModel.updateUser(Global.profile.user!);
                                UserModel().notifyListeners();
                            }
                          },
                          child: Text(_user.isFollow == 1 ? '已关注' : '关注',
                              style: const TextStyle(color: Colors.white))
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(30)),
                    SizedBox(
                      width: ScreenUtil().setWidth(60),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          // padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: Colors.white54,
                        ),
                        child: Icon(
                          _user.userId == _localUser.userId
                              ? MyIcons.qr_code
                              : MyAppIcon.envelope_regular,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => _user.userId == _localUser.userId
                                  ? QrPage(user: _user)
                                  : ChatPage(user: _user),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 1,child: Container(),),
              Text(
                _user.username ?? "用户${_user.userId.toString()}",
                // "用户${_user.userId.toString()}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(26),
                    color: Colors.white),
              ),
              Expanded(flex: 1,child: Container(),),
              Text(
                  _user.bio ?? '这个人很懒，什么都没写',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      color: Colors.white)),
              Expanded(flex: 1,child: Container()),
              Row(
                children: <Widget>[
                  Text(
                    _user.followNum == null ? '0':_user.followNum.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(25)),
                  ),
                  const Text(
                    ' 关注  ',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _user.fanNum == null ? '0':_user.fanNum.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(25)),
                  ),
                  const Text(' 粉丝', style: TextStyle(color: Colors.white)),
                ],
              ),
              Expanded(flex: 1,child: Container(),),
              infoRow(),
              Expanded(flex: 2,child: Container(),),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: Consumer<ThemeModel>(
          builder:  (BuildContext context, themeModel, _) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.all(0),
              child: TabBar(
                onTap: (index) {
                  _pageController.jumpToPage(index);
                },
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor: themeModel.isDark?Colors.white:Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w300),
                tabs: const <Widget>[
                  Tab(text:'动态'),
                  Tab(text:'闲置'),
                  Tab(text:'活动')
                ],
              ),
            );
          },
        ),
      ),
    );

  }

  Row infoRow() {
    return Row(
      children: <Widget>[
        //offstage是隐藏的，当gender为2时，不显示性别
        Offstage(
          offstage: _user.gender == 2,
          child: Container(
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(15)),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(4),
                horizontal: ScreenUtil().setWidth(20)),
            decoration: BoxDecoration(
                color: _user.gender == 1
                    ?Colors.blue[300]?.withOpacity(0.7)
                    :Colors.pink[300]?.withOpacity(0.7),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))
            ),
            child: Row(
              children: <Widget>[
                Icon(_user.gender == 0
                    ?MyAppIcon.female
                    :MyAppIcon.male,
                  size: ScreenUtil().setWidth(14),
                  color: Colors.white,
                ),
                Offstage(
                    //当生日为空时，不显示年龄
                    offstage: _user.birthDay==null,
                    child: Text(
                      ' ${ageBuilder()}岁',
                      // style: TextStyle(fontSize: ScreenUtil().setSp(33)),
                    )
                ),
              ],
            ),
          ),
        ),
        Offstage(
          offstage: _user.city == ''||_user.city==null,
          child: Container(
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(4),
                horizontal: ScreenUtil().setWidth(20)),
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))
            ),
            child:
            // Text(_user.city == ''||_user.city==null?'':_user.city?.split('.')[1],
            Text(_user.city == null || _user.city!.isEmpty ? '' : _user.city!.split('.')[1],
              // style: TextStyle(fontSize: ScreenUtil().setSp(33),),
            ),
          ),
        ),
        Offstage(
          offstage: _user.birthDay == ''||_user.birthDay==null,
          child: Container(
            margin: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(2),
                horizontal: ScreenUtil().setWidth(20)),
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))
            ),
            child: Text(
              starSign(),
              // style: TextStyle(fontSize: ScreenUtil().setSp(33)),
            ),
          ),
        ),

      ],
    );
  }

  Future<void> _getUser() async {
    int askId = _localUser!.userId!;
    var res;
    if(widget.userId != null){
      res = await NetRequester.request(Apis.findUserById(widget.userId!));
    }
    else{
      res = await NetRequester.request(Apis.findUserByName(askId, widget.username!));
    }
    if(res['code'] == '0'){
      Toast.popToast('用户不存在');
      Future.delayed(const Duration(milliseconds: 500), (){
        Navigator.pop(context);
      });
    }else{
      _user = User.fromJson(res["data"]);
      _postRepository =  PostRepository(_user.userId!,1);
      if(widget.userId == askId || widget.username == _localUser.username){
        Global.profile.user =_user;
        final userModel = Provider.of<UserModel>(context, listen: false);
        userModel.updateUser(Global.profile.user!);
      }
    }
  }

  String ageBuilder() {

    // 默认日期，用于处理 null 或无效格式
    String defaultDate = '2024-01-01';

    DateTime date;
    try {
      // 尝试解析 _user.birthDay
      date = DateTime.parse(_user.birthDay ?? defaultDate);
    } catch (e) {
      // 如果解析失败，使用默认日期
      print('日期格式无效，使用默认日期: $defaultDate');
      date = DateTime.parse(defaultDate);
    }

    // print(date);

    var now = DateTime.now();
    // print(now);

    var age = now.year - date.year;
    // print(age);

    return age.toString();
  }

  String starSign() {
    // 默认日期，用于处理 null 或无效格式
    String defaultDate = '2024-01-01';

    DateTime birthDay;
    try {
      // 尝试解析 _user.birthDay
      birthDay = DateTime.parse(_user.birthDay ?? defaultDate);
    } catch (e) {
      // 如果解析失败，使用默认日期
      // print('日期格式无效，使用默认日期: $defaultDate');
      birthDay = DateTime.parse(defaultDate);
    }

    var month = birthDay.month;
    var day = birthDay.day;
    String starSign = '';

    switch (month) {
      case 1:
        starSign = day < 21 ? '摩羯座' : '水瓶座';
        break;
      case 2:
        starSign = day < 20 ? '水瓶座' : '双鱼座';
        break;
      case 3:
        starSign = day < 21 ? '双鱼座' : '白羊座';
        break;
      case 4:
        starSign = day < 21 ? '白羊座' : '金牛座';
        break;
      case 5:
        starSign = day < 22 ? '金牛座' : '双子座';
        break;
      case 6:
        starSign = day < 22 ? '双子座' : '巨蟹座';
        break;
      case 7:
        starSign = day < 23 ? '巨蟹座' : '狮子座';
        break;
      case 8:
        starSign = day < 24 ? '狮子座' : '处女座';
        break;
      case 9:
        starSign = day < 24 ? '处女座' : '天秤座';
        break;
      case 10:
        starSign = day < 24 ? '天秤座' : '天蝎座';
        break;
      case 11:
        starSign = day < 23 ? '天蝎座' : '射手座';
        break;
      case 12:
        starSign = day < 22 ? '射手座' : '摩羯座';
        break;
    }
    return starSign;
  }
}



