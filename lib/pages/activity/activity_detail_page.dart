import 'package:client/core/global.dart';
import 'package:client/core/list_repository/discuss_repo.dart';
import 'package:client/core/model/activity.dart';
import 'package:client/core/net/my_api.dart';
import 'package:client/core/net/net.dart';
import 'package:client/core/net/net_request.dart';
import 'package:client/util/build_date.dart';
import 'package:client/util/toast.dart';
import 'package:client/widget/image_build.dart';
import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/model/discuss.dart';
import '../../widget/build_indicator.dart';
import '../../widget/error_widget.dart';

class ActivityDetailPage extends StatefulWidget {
  final int? activityId;
  const ActivityDetailPage({super.key, required this.activityId});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late DiscussRepo _discussRepo;
  late Future<void> _initialActivity;
  final TextEditingController _controller=TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Discuss? _replyToDiscuss;
  Activity? _activity;
  late bool isFavorite;
  @override
  void initState() {
    super.initState();
    _initialActivity = _getActivity();
    _focusNode.addListener(_focusNodeListener);
  }
  void _focusNodeListener() {
    if (!_focusNode.hasFocus) {
      setState(() => _replyToDiscuss = null);
    }
  }
  @override
  void dispose() {
    _focusNode.removeListener(_focusNodeListener); // 移除监听
    _focusNode.dispose(); // 释放资源
    _controller.dispose(); // 释放输入控制器
    _discussRepo.dispose();
    super.dispose();
  }


  Future<void> _getActivity() async {
    try {
      var response = await NetRequester.request(Apis.getActivityDetails(widget.activityId!));
      if (response['code'] == '1') {
        setState(() {
          _activity = Activity.fromJson(response['data']);
          isFavorite = _activity!.isPraised==1?true:false;
        });
        _discussRepo = DiscussRepo(_activity!.activityId!);
      }
    } catch (e) {
      print('Error fetching activity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialActivity,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || _activity == null) {
            return MyErrorWidget(
              message: _activity == null ? '活动已被删除' : '加载失败，请稍后重试',
              onClose: () => Navigator.pop(context),
              countdownSeconds: 3,
              icon: _activity == null ? Icons.delete_forever : Icons.error_outline,
              actions: [
                if (_activity == null)
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/root'),
                    child: const Text('返回首页'),
                  ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('返回上一页'),
                ),
              ],
            );
          }
          return Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.translucent, // 允许点击空白处
              onTap: () {
                FocusScope.of(context).unfocus(); // 取消焦点
              },
              child: Stack(
                children: [
                  _buildBody(),
                  _buildInputBar(),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: SpinKitRing(
              lineWidth: 3,
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  Widget _buildBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var pinnedHeaderHeight = statusBarHeight + kToolbarHeight + 120.w;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: extended.ExtendedNestedScrollView(
        headerSliverBuilder: _headerSliverBuilder,
        pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
        body: Container(
          color: Colors.grey[200],
          child: LoadingMoreList(
            ListConfig<Discuss>(
              sourceList: _discussRepo,
              itemBuilder: (context, item, index) => _buildCommentItem(item),
              padding: EdgeInsets.all(12.w),
              indicatorBuilder: _buildIndicator,
            ),
          )
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status){
    return buildIndicator(context, status, _discussRepo);
  }

  Widget _buildCommentItem(Discuss comment, {int depth = 0}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _handleReply(comment);
      },
      child: Padding(
        padding: EdgeInsets.only(left: depth * 20.w, top: 12.w, ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16.w,
                  backgroundImage: NetworkImage('${NetConfig.ip}/images/${comment.avatarUrl}'),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(comment.username!,
                              style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                          SizedBox(width: 5.w),
                          Text(
                            formatCommentTime(comment.createTime!),
                            style: TextStyle(fontSize: 12.w, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      if (comment.replyTo != null && comment.replyTo!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 2.w),
                          child: Text('回复 ${comment.replyTo}: ',
                              style: TextStyle(fontSize: 12.w, color: Colors.blue)),
                        ),
                      SizedBox(height: 4.w),
                      Text(comment.content!,
                          style: TextStyle(fontSize: 14.w, color: Colors.grey[800], height: 1.4)),
                      SizedBox(height: 4.w),
                    ],
                  ),
                ),
              ],
            ),
            if (comment.children!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Column(
                  children: comment.children!.map((child) => _buildCommentItem(child, depth: depth + 1)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleReply(Discuss comment) {
    setState(() => _replyToDiscuss = comment);
    print(_replyToDiscuss?.toJson());
    FocusScope.of(context).requestFocus(_focusNode);
  }

  // List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
  //   return [
  //     SliverAppBar(
  //       pinned: true,
  //       title: const Text('活动详情'),
  //       // actions: [
  //       //   // 条件判断：当前用户是活动主持人时显示操作按钮
  //       //   if (_activity != null && Global.profile.user?.userId == _activity!.hostUserId)
  //       //     TextButton(
  //       //       onPressed: (){
  //       //         _showCancelConfirmDialog(context);
  //       //       },
  //       //       child: const Icon(Icons.more_horiz),
  //       //     ),
  //       // ],
  //         // 修改 SliverAppBar 的 actions 部分
  //         actions: [
  //           if (_activity != null && Global.profile.user?.userId == _activity!.hostUserId)
  //             PopupMenuButton<String>(
  //               icon: const Icon(Icons.more_horiz),
  //               onSelected: (value) {
  //                 if (value == 'cancel') {
  //                   _showCancelConfirmDialog(context);
  //                 }
  //               },
  //               itemBuilder: (BuildContext context) => [
  //                 PopupMenuItem<String>(
  //                   value: 'cancel',
  //                   child: Row(
  //                     children: [
  //                       Icon(Icons.cancel, color: Colors.red, size: 20.w),
  //                       SizedBox(width: 8.w),
  //                       Text('取消活动', style: TextStyle(fontSize: 14.w)),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //         ]
  //     ),
  //     if (_activity != null) _activityInfo(),
  //   ];
  // }
  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return [
      SliverAppBar(
        pinned: true,
        title: const Text('活动详情'),
        actions: [
          if (_activity != null && Global.profile.user?.userId == _activity!.hostUserId)
            Padding(
              padding: EdgeInsets.only(right: 12.w), // 增加右侧边距防止贴边
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                offset: Offset(0, 40.w), // 控制下拉菜单垂直偏移
                onSelected: (value) {
                  if (value == 'cancel') {
                    _showCancelConfirmDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red, size: 20.w),
                        SizedBox(width: 8.w),
                        Text('取消活动', style: TextStyle(fontSize: 14.w)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      if (_activity != null) _activityInfo(),
    ];
  }

  Widget _activityInfo() {
    final List<String> images = _activity!.activityImage!.split('￥');
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, blurRadius: 8, spreadRadius: 2)
            ],
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageBuild.carouselImages(context, _activity!.activityId!, images),
              _buildDetailRow('活动名称', _activity!.activityName),
              _buildDetailRow('活动内容', _activity!.details),
              _buildDetailRow('开始时间', buildActivityTime(_activity!.activityTime!)),
              _buildDetailRow('活动地点', _activity!.location),
              _buildDetailRow('报名人数', '${_activity?.currentParticipants}/${_activity?.maxParticipants}'),
              // TextButton(
              //   onPressed: () async {
              //     // 新增组织者判断
              //     if (Global.profile.user?.userId == _activity!.hostUserId) {
              //       Toast.popToast('你是活动组织者');
              //       return;
              //     }
              //     if (_activity!.isRegistered == 1) {
              //       // 取消报名逻辑保持不变
              //       var res = await NetRequester.request(Apis.cancelRegister(_activity!.activityId!));
              //       if (res['code'] == '1') {
              //         Toast.popToast('取消报名成功');
              //         setState(() {
              //           _activity!
              //             ..currentParticipants = _activity!.currentParticipants! - 1
              //             ..isRegistered = 0;
              //         });
              //       } else {
              //         Toast.popToast('取消报名失败');
              //       }
              //     } else {
              //       // 报名逻辑保持不变
              //       if (_activity!.currentParticipants! < _activity!.maxParticipants!) {
              //         var res = await NetRequester.request(Apis.registerActivity(_activity!.activityId!));
              //         if (res['code'] == '1') {
              //           Toast.popToast('报名成功');
              //           setState(() {
              //             _activity!
              //               ..currentParticipants = _activity!.currentParticipants! + 1
              //               ..isRegistered = 1;
              //           });
              //         } else {
              //           Toast.popToast('报名失败');
              //         }
              //       } else {
              //         Toast.popToast('报名人数已满');
              //       }
              //     }
              //   },
              //   child: Center(
              //     child: Text(_activity!.isRegistered == 1 ? '取消报名' : '我要报名'),
              //   ),
              // )
              _buildRegistrationButton(), // 这里替换
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildRegistrationButton() {
    // 空值安全判断
    if (_activity == null) return const SizedBox.shrink();

    final isHost = Global.profile.user?.userId == _activity!.hostUserId;
    final isFull = _activity!.currentParticipants! >= _activity!.maxParticipants!;

    // 直接使用 activity.status 判断状态
    if (_activity!.status == 0) { // 假设 status=2 表示已取消
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.w),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Center(
          child: Text(
              '活动已取消',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.w,
                  fontWeight: FontWeight.w500)),
        ),
      );
    }

    // 正常状态按钮
    return TextButton(
      onPressed: () => _handleRegistration(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            _activity!.isRegistered == 1 ? Colors.grey[300] : Theme.of(context).primaryColor),
        minimumSize: MaterialStateProperty.all(Size(double.infinity, 44.w)),
      ),
      child: Text(
          _activity!.isRegistered == 1 ? '取消报名' : '我要报名',
          style: TextStyle(
              color: _activity!.isRegistered == 1 ? Colors.grey[600] : Colors.white,
              fontSize: 16.w)),
    );
  }

// 取消活动的方法需要更新状态字段
  void cancelActivity() async {
    var res = await NetRequester.request(Apis.cancelActivity(widget.activityId));
    if(res['code']=='1'){
      Toast.popToast('取消活动成功');
      setState(() {
        // 直接更新活动状态
        _activity!.status = 0; // 假设 2 表示已取消
      });
    }else{
      Toast.popToast('取消活动失败');
    }
  }
// 在 class 中添加方法：
  void _handleRegistration() async {
    if (_activity == null) return;

    // 组织者判断
    if (Global.profile.user?.userId == _activity!.hostUserId) {
      Toast.popToast('你是活动组织者');
      return;
    }

    try {
      if (_activity!.isRegistered == 1) {
        // 取消报名逻辑
        var res = await NetRequester.request(Apis.cancelRegister(_activity!.activityId!));
        if (res['code'] == '1') {
          setState(() {
            _activity!
              ..currentParticipants = _activity!.currentParticipants! - 1
              ..isRegistered = 0;
          });
          Toast.popToast('取消报名成功');
        }
      } else {
        // 报名逻辑
        if (_activity!.currentParticipants! >= _activity!.maxParticipants!) {
          Toast.popToast('报名人数已满');
          return;
        }
        var res = await NetRequester.request(Apis.registerActivity(_activity!.activityId!));
        if (res['code'] == '1') {
          setState(() {
            _activity!
              ..currentParticipants = _activity!.currentParticipants! + 1
              ..isRegistered = 1;
          });
          Toast.popToast('报名成功');
        }
      }
    } catch (e) {
      print('报名操作异常: $e');
      Toast.popToast('操作失败，请重试');
    }
  }
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value ?? '无', style: const TextStyle(fontSize: 18, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 收起键盘
        },
        child: Material(
          // elevation: 8,
          child: Container(
            height: 60.w, // 保持 Container 高度为 60
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: _replyToDiscuss != null
                          ? '回复 ${_replyToDiscuss!.username}'
                          : '发表评论...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.w), // 边框圆角
                        borderSide: const BorderSide(width: 1, color: Colors.grey), // 边框宽度和颜色
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.w), // 启用状态下的边框设置
                        borderSide: const BorderSide(width: 1, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.w), // 聚焦状态下边框设置
                        borderSide: const BorderSide(width: 2, color: Colors.blue), // 聚焦边框颜色
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 12.w), // 增加内部边距
                    ),
                  ),
                ),
                // SizedBox(width: 10.w),
                IconButton(
                    onPressed: ()async{
                      String url= isFavorite ? Apis.cancelPraiseActivity(_activity!.activityId!):Apis.praiseActivity(_activity!.activityId!);
                      var res = await NetRequester.request(url);
                      if(res['code']=='1'){
                        Toast.popToast(isFavorite ? '取消点赞成功' : '点赞成功');
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      }else {
                        Toast.popToast(isFavorite? '取消点赞失败' :'点赞失败');
                      }
                    },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                ),
                IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // 提交评论或回复
  _submitComment() async {
    if (_controller.text.isEmpty) return;
    print(_controller.text);
    final Map<String, dynamic> map;
    final String url;
    try {
      String content = _controller.text;
      if (_replyToDiscuss != null) {
        if(_replyToDiscuss!.replyId == 0 &&_replyToDiscuss!.parentId == 0){
          //回复主评论
          map={
            'userId': Global.profile.user?.userId,
            'activityId': widget.activityId,
            'replyId': _replyToDiscuss!.discussId,
            'parentId': _replyToDiscuss!.discussId,
            'content': content,
          };
        }else{
          // 回复回复
          map={
            'userId': Global.profile.user?.userId,
            'activityId': widget.activityId,
            'replyId': _replyToDiscuss!.discussId,
            'parentId': _replyToDiscuss!.parentId,
            'content': content,
          };
        }
      } else {
        // 发表评论
        map={
          'userId': Global.profile.user?.userId,
          'activityId': widget.activityId,
          'replyId': 0,
          'parentId': 0,
          'content': content,
        };
      }
      url= '/activityComment/add';
      try {
        final response = await NetRequester.request(url,data: map);
        if (response['code'] == '1') {
          Toast.popToast('评论成功');
            _discussRepo.refresh();
        } else {
          Toast.popToast('评论失败');
        }
      } catch (e) {
        print('Error submitting comment: $e');
      }
      // 更新评论列表
      setState(() {
        _controller.clear();
        _replyToDiscuss = null; // 重置回复目标
      });
    } catch (e) {
      print('Error submitting comment: $e');
    }
  }

  // cancelActivity() async{
  //     var res = await NetRequester.request(Apis.cancelActivity(widget.activityId));
  //     if(res['code']=='1'){
  //       Toast.popToast('取消活动成功');
  //       Navigator.pop(context);
  //     }else{
  //       Toast.popToast('取消活动失败');
  //     }
  // }
  // void _showCancelConfirmDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('确认取消活动'),
  //       content: const Text('确定要取消当前活动吗？此操作不可恢复'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('再想想'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context); // 关闭对话框
  //             cancelActivity();      // 执行取消逻辑
  //           },
  //           style: TextButton.styleFrom(
  //             foregroundColor: Colors.red, // 强调危险操作
  //           ),
  //           child: const Text('确认取消'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showCancelConfirmDialog(BuildContext context) {
    final isCanceled = _activity?.status == 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCanceled ? '活动已取消' : '确认取消活动'),
        content: Text(isCanceled
            ? '该活动已处于取消状态'
            : '确定要取消当前活动吗？此操作不可恢复'),
        actions: [
          if (!isCanceled) ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('再想想'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cancelActivity();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('确认取消'),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知道了'),
            ),
          ]
        ],
      ),
    );
  }
}
