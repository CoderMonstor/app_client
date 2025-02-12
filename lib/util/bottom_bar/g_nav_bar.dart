import 'package:flutter/material.dart';
import 'g_button.dart';
import 'g_nav.dart';

class GNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTabChange;

  const GNavBar({
    super.key,
    required this.selectedIndex,
    this.onTabChange,
  });

  void _defaultOnTabChange(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/resale');
        break;
      case 2:
        Navigator.pushNamed(context, '/gather');
        break;
      case 3:
        Navigator.pushNamed(context, '/about_me');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GNav(
      selectedIndex: selectedIndex,
      onTabChange: (index) {
        if (onTabChange != null) {
          onTabChange!(index);
        } else {
          _defaultOnTabChange(context, index);
        }
      },
      tabs: const [
        GButton(
          icon: Icons.home,
          text: '广场',
        ),
        GButton(
          icon: Icons.monetization_on,
          text: '交易',
        ),
        GButton(
          icon: Icons.campaign,
          text: '活动',
        ),
        GButton(
          icon: Icons.person,
          text: '个人',
        ),
      ],
    );
  }
}