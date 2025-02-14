import 'package:flutter/material.dart';
import '../../util/app_bar/my_app_bar.dart';
import 'common_post.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key});

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late TabController _tabController;
  late PageController _pageController;
  List<Widget> _pageList = []; //列表存放页面
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageList..add(const CommonPostPage(type: 6))..add(const CommonPostPage(type: 5));
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    var _tabBar =  TabBar(
      onTap: (index) {
        _pageController.jumpToPage(index);
      },
      controller: _tabController,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const <Widget>[
        Tab(text:'热门'),
        Tab(text:'最新'),
      ],
    );
    return Scaffold(
      // appBar: MyAppbar.build(context,_tabBar),

      body: PageView(
        controller: _pageController,
        children: _pageList,
        onPageChanged: (index) {
          _tabController.animateTo(index);
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
