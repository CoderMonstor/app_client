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
  final GlobalKey _fabKey = GlobalKey(); // 用于定位FAB位置
  final List<Widget> _pageList = [];
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageList
      ..add(const CommonPostPage(type: 5))
      ..add(const CommonPostPage(type: 6))
      ..add(const CommonPostPage(type: 2));
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
  }

  // 处理外部点击
  void _handleOutsideTap(PointerDownEvent event) {
    final RenderBox? fabRenderBox =
    _fabKey.currentContext?.findRenderObject() as RenderBox?;

    if (fabRenderBox != null && _isFabExpanded) {
      final fabSize = fabRenderBox.size;
      final fabOffset = fabRenderBox.localToGlobal(Offset.zero);

      final tapPosition = event.position;
      final isInsideFab = tapPosition.dx >= fabOffset.dx &&
          tapPosition.dx <= fabOffset.dx + fabSize.width &&
          tapPosition.dy >= fabOffset.dy &&
          tapPosition.dy <= fabOffset.dy + fabSize.height;

      if (!isInsideFab) {
        setState(() => _isFabExpanded = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      onTap: (index) => _pageController.jumpToPage(index),
      controller: _tabController,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const <Widget>[
        Tab(text: '最新'),
        Tab(text: '热门'),
        Tab(text: '关注'),
      ],
    );

    return Listener(
      onPointerDown: _handleOutsideTap, // 监听全局点击
      child: Scaffold(
        appBar: MyAppbar.buildNormalAppbar(context, false, true, null, tabBar),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) =>
              setState(() => _tabController.index = index),
          children: _pageList,
        ),
        floatingActionButton: SendButton(
          key: _fabKey, // 绑定GlobalKey
          isExpanded: _isFabExpanded,
          onToggle: (value) => setState(() => _isFabExpanded = value),
        ),
      ),
    );
  }
}