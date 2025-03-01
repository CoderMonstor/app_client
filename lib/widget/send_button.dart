import 'package:client/pages/gather/send_gather.dart';
import 'package:client/pages/post/send_post.dart';
import 'package:client/pages/resale/buying_request_page.dart';
import 'package:client/pages/resale/send_resale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SendButton extends StatefulWidget {
  const SendButton({super.key});

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;
  final List<IconData> _icons = [
    Icons.ac_unit,
    Icons.cabin,
    Icons.ice_skating,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  void _navigateToPage(int index) {
    const pages = [SendResalePage(),BuyingRequestPage(),SendGatherPage()];
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => pages[index]),
    );
    _toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    final fabSize = ScreenUtil().setWidth(56); // 主按钮尺寸
    final miniFabSize = ScreenUtil().setWidth(40); // 子按钮尺寸
    final spacing = ScreenUtil().setWidth(16); // 按钮间距
    return Padding(
      padding: const EdgeInsets.only(bottom: 50), // 增加底部空间
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // 展开的子按钮
          ...List.generate(_icons.length, (index) {
            final offsetY = (fabSize + spacing) * (index + 1)+ScreenUtil().setHeight(20);
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: 16,
              bottom: _isExpanded
                  ? offsetY // 动态计算垂直位置
                  : -miniFabSize, // 隐藏到屏幕下方
              child: _buildChildButton(index),
            );
          }),
          // 主按钮（必须最后渲染）
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildMainButton(),
          ),
          // 主按钮
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return FloatingActionButton(
      onPressed: _toggleMenu,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isExpanded
            ? IconButton(onPressed: (){
              Navigator.push(context, CupertinoPageRoute(builder: (context)=>const SendPostPage(type: 1,)));
        },
              icon: const Icon(Icons.accessibility_new_rounded))
            : const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChildButton(int index) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
      ),
      child: FadeTransition(
        opacity: _controller,
        child: FloatingActionButton(
          heroTag: 'btn$index',
          onPressed: () => _navigateToPage(index),
          child: Icon(_icons[index]),
        ),
      ),
    );
  }
}
