import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:client/widget/send_button.dart';
import 'package:flutter/material.dart';
import 'common_post.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  List<Widget> _pageList = []; //列表存放页面
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageList..add(const CommonPostPage(type: 6))..add(const CommonPostPage(type: 5))..add(const CommonPostPage(type: 2));
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tabBar = TabBar(
      onTap: (index) {
        _pageController.jumpToPage(index);
      },
      controller: _tabController,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const <Widget>[
        Tab(text: '热门'),
        Tab(text: '最新'),
        Tab(text: '关注')
      ],
    );
    return Scaffold(
      appBar: MyAppbar.buildNormalAppbar(context, false, true, null, tabBar),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.index = index;
          });
        },
        children: _pageList,
      ),
      floatingActionButton: const SendButton(),
    );
  }
}
