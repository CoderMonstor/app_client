import 'package:client/pages/resale/quilted_goods.dart';
import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';
import '../../widget/send_button.dart';

class ResalePage extends StatefulWidget {
  const ResalePage({super.key});

  @override
  State<ResalePage> createState() => _ResalePageState();
}
class _ResalePageState extends State<ResalePage> with TickerProviderStateMixin {
  bool _isFabExpanded = false;
  late TabController _tabController;
  late PageController _pageController;
  final List<Widget> _pageList = [];
  final GlobalKey _fabKey = GlobalKey();

  @override
  initState() {
    super.initState();
    _pageList..add(const QuiltedGoods(type: 1,))
             ..add(const QuiltedGoods(type: 2,));
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }
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
      onTap: (index) =>_pageController.jumpToPage(index),
      controller: _tabController,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const [
        Tab(text: '出售'),
        Tab(text: '求购'),
      ],
    );
    return Listener(
      onPointerDown: _handleOutsideTap,
      child: Scaffold(
        appBar: MyAppbar.buildNormalAppbar(context, false, true, null, tabBar),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) =>setState(() {
            _tabController.index = index;
          }),
          children: _pageList,
        ),
        floatingActionButton: SendButton(
          key: _fabKey,
          isExpanded: _isFabExpanded,
          onToggle: (value) => setState(() => _isFabExpanded = value),
        ),
      ),
    );
  }

}

