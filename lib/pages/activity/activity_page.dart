import 'package:client/core/list_repository/activity_repo.dart';
import 'package:client/pages/activity/common_activity.dart';
import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:client/widget/my_card/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/model/activity.dart';
import '../../widget/send_button.dart';


class GatherPage extends StatefulWidget {
  const GatherPage({super.key});


  @override
  State<GatherPage> createState() => _GatherPageState();
}

class _GatherPageState extends State<GatherPage> {
  final GlobalKey _fabKey = GlobalKey(); // 用于定位FAB位置
  bool _isFabExpanded = false;
  late ActivityRepo _activityRepo;
  /// 处理外部点击事件，用于判断点击位置是否在Floating Action Button (FAB) 外部，
  /// 如果在外部且FAB处于展开状态，则将其收起。
  ///
  /// 参数:
  ///   - `event`: PointerDownEvent对象，包含点击事件的位置信息。
  ///
  /// 返回值:
  ///   - 无返回值，但会根据点击位置更新FAB的展开状态。
  void _handleOutsideTap(PointerDownEvent event) {
    // 获取FAB的渲染对象，用于计算FAB的位置和大小
    final RenderBox? fabRenderBox =
    _fabKey.currentContext?.findRenderObject() as RenderBox?;

    // 如果FAB的渲染对象存在且FAB处于展开状态
    if (fabRenderBox != null && _isFabExpanded) {
      // 获取FAB的大小和位置
      final fabSize = fabRenderBox.size;
      final fabOffset = fabRenderBox.localToGlobal(Offset.zero);

      // 获取点击事件的位置
      final tapPosition = event.position;

      // 判断点击位置是否在FAB内部
      final isInsideFab = tapPosition.dx >= fabOffset.dx &&
          tapPosition.dx <= fabOffset.dx + fabSize.width &&
          tapPosition.dy >= fabOffset.dy &&
          tapPosition.dy <= fabOffset.dy + fabSize.height;

      // 如果点击位置在FAB外部，则收起FAB
      if (!isInsideFab) {
        setState(() => _isFabExpanded = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initialData();
  }

  Future<void> _initialData() async {
    _activityRepo = ActivityRepo(Global.profile.user!.userId!,1);
  }

  @override
  void dispose() {
    super.dispose();
    _activityRepo.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleOutsideTap,
      child: Scaffold(
        appBar: MyAppbar.buildNormalAppbar(context, false, true, null, null),
        body:  const CommonActivity(type: 1),
        floatingActionButton: SendButton(
          key: _fabKey, // 绑定GlobalKey
          isExpanded: _isFabExpanded,
          onToggle: (value) => setState(() => _isFabExpanded = value),
        ),
      ),
    );
  }
}
