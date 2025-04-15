import 'package:client/pages/post/send_post.dart';
import 'package:client/pages/resale/post_resale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/activity/post_activity.dart';

class SendButton extends StatefulWidget {
  final ValueChanged<bool> onToggle;
  final bool isExpanded;

  const SendButton({
    super.key,
    required this.onToggle,
    required this.isExpanded,
  });

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, dynamic>> _buttons = [

    {
      'icon': Icons.post_add, // 普通发帖图标
      'page': const SendPostPage(type: 1),
    },
    {
      'icon': Icons.sell, // 商品转售图标
      'page': const SendResalePage(),
    },
    {
      'icon': Icons.event, // 活动发布图标
      'page': const PostActivityPage(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant SendButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _syncAnimationState();
    }
  }

  void _syncAnimationState() {
    widget.isExpanded ? _controller.forward() : _controller.reverse();
  }

  void _toggleMenu() => widget.onToggle(!widget.isExpanded);

  void _navigateToPage(int index) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => _buttons[index]['page']),
    );
    _toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    final fabSize = ScreenUtil().setWidth(56);
    final miniFabSize = ScreenUtil().setWidth(40);
    final spacing = ScreenUtil().setWidth(16);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          ...List.generate(_buttons.length, (index) {
            final offsetY = (fabSize + spacing) * (index + 1) + ScreenUtil().setHeight(20);
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: 16,
              bottom: widget.isExpanded ? offsetY : -miniFabSize,
              child: _buildChildButton(index),
            );
          }),
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildMainButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return FloatingActionButton(
      onPressed: _toggleMenu,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: animation,
          child: child,
        ),
        child: widget.isExpanded
            ? const Icon(Icons.close, key: ValueKey('close'))
            : const Icon(Icons.add, key: ValueKey('add')),
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
          heroTag: 'fab_$index',
          onPressed: () => _navigateToPage(index),
          child: Icon(_buttons[index]['icon']),
        ),
      ),
    );
  }
}