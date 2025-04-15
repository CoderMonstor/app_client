import 'package:client/pages/activity/common_activity.dart';
import 'package:client/pages/resale/common_goods_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/global.dart';
import '../../util/my_icon/my_icon.dart';
import '../post/common_post.dart';
import '../user/common_user_page.dart';

class SearchPage extends StatefulWidget{
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>  with TickerProviderStateMixin {

  final TextEditingController _editingController =TextEditingController();
  late TabController _tabController;
  late PageController _pageController;
  late bool _showTabBar;
  late String str;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _showTabBar=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _pageController = PageController(initialPage: _tabController.index);
    return Scaffold(
      appBar: AppBar(
        // 隐藏阴影
        elevation: 0,
        //自动隐藏AppBar
        automaticallyImplyLeading: false,
        title: _searchBar(),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(_showTabBar?30:0),
            child: _showTabBar
                ?SizedBox(
                height: 30,
                child: TabBar(
                  onTap: (index){
                    _pageController.jumpToPage(index);
                  },
                  // labelPadding: EdgeInsets.only(bottom: ScreenUtil().setHeight(18)),
                  controller: _tabController,
                  tabs: const <Widget>[
                    Tab(text: '帖子'),
                    Tab(text: '用户'),
                    Tab(text: '交易'),
                    Tab(text: '活动'),
                  ],
                ))
                :Container()
        ),
      ),
      body: _showTabBar?PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        children: <Widget>[
          CommonPostPage(type: 7,orderBy: 'hot',str: str,userId: Global.profile.user?.userId,),
          CommonUserPage(str: str),
          CommonGoodsPage(type: 5,str: str,userId: Global.profile.user?.userId,),
          CommonActivity(type: 4,str: str,userId: Global.profile.user?.userId,)
        ],
      ):_buildSearchHistory(),
    );
  }

  SizedBox _searchBar() {
    return SizedBox(
      child: Stack(
        children: <Widget>[
          CupertinoTextField(
              onEditingComplete: (){
                sendHandler();
              },
              onTap: (){
                setState(() {
                  _showTabBar = false;
                });
              },
              focusNode: _focusNode,
              controller: _editingController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(24)),
              prefix: IconButton(
                // padding: const EdgeInsets.all(0),
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back,size: ScreenUtil().setWidth(30),
                  color: Colors.black54,),
              ),
              placeholder: '搜索 . . . .',
              placeholderStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: ScreenUtil().setSp(22)),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(21)
              )
          ),
          Positioned(
            right: ScreenUtil().setWidth(0),
            child:SizedBox(
              width: ScreenUtil().setWidth(60),
              height: ScreenUtil().setHeight(50),
              child: IconButton(
                // padding: EdgeInsets.all(0),
                onPressed: (){
                  sendHandler();
                },
                icon: Icon(MyIcons.search,size: ScreenUtil().setWidth(30),
                  color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendHandler() {
    if (_editingController.text.isNotEmpty) {
      _focusNode.unfocus();
      setState(() {
        _showTabBar = true;
        str = _editingController.text;
        // 确保 searchList 为可变列表
        if (Global.profile.searchList == null) {
          Global.profile.searchList = [];
        } else {
          Global.profile.searchList = List<String>.from(Global.profile.searchList!);
        }

        if (Global.profile.searchList!.contains(str)) {
          Global.profile.searchList?.remove(str);
          Global.profile.searchList?.insert(0, str);
        } else {
          Global.profile.searchList?.insert(0, str);
        }
        Global.saveProfile();
      });
    }
  }


  _buildSearchHistory(){
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(42),
          vertical: ScreenUtil().setHeight(40)),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('搜索历史',style: TextStyle(fontSize: ScreenUtil().setSp(22))),
              TextButton.icon(
                onPressed: () {
                  Global.profile.searchList?.clear();
                  Global.saveProfile();
                  setState(() {});
                },
                icon: Icon(Icons.delete, color: Colors.grey, size: ScreenUtil().setWidth(20)),
                label: Text('清除', style: TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(18))),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setHeight(10)),
              Global.profile.searchList!.isEmpty
              ?Container()
              :Wrap(
            spacing: ScreenUtil().setWidth(20),
            children: List<Widget>.generate(
              Global.profile.searchList!.length,
                  (int index) {
                return _buildItem(index);
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  _buildItem(int index) {
    String? content = Global.profile.searchList?[index];
    return ActionChip(
      label: Text(content!, style: TextStyle(fontSize: ScreenUtil().setSp(18))),
      backgroundColor: Colors.black.withOpacity(0.1),
      labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: ScreenUtil().setWidth(10)),
      onPressed: () {
        _focusNode.unfocus();
        setState(() {
          _showTabBar = true;
          str = content;
          _editingController.text = content;
          // 确保搜索历史列表为可变列表
          Global.profile.searchList = List<String>.from(Global.profile.searchList!);
          Global.profile.searchList?.removeAt(index);
          Global.profile.searchList?.insert(0, str);
          Global.saveProfile();
        });
      },
    );
  }


}