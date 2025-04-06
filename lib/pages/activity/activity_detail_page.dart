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
            return const Center(child: Text('加载失败，请稍后重试', style: TextStyle(fontSize: 18)));
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
  // 提交回复
  void _submitReply(Discuss comment, String replyContent) {
    if (replyContent.isNotEmpty) {
      // 提交回复的逻辑
    }
  }

// 评论提交
  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return [
      const SliverAppBar(
        pinned: true,
        title: Text('活动详情'),
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
              TextButton(
                onPressed: () async {
                  if (_activity!.isRegistered == 1) {
                    // 取消报名
                    var res = await NetRequester.request(Apis.cancelRegister(_activity!.activityId!));
                    if (res['code'] == '1') {
                      Toast.popToast('取消报名成功');
                      setState(() {
                        _activity!
                          ..currentParticipants = _activity!.currentParticipants! - 1
                          ..isRegistered = 0; // 增加状态更新
                      });
                    } else {
                      Toast.popToast('取消报名失败');
                    }
                  } else {
                    // 报名
                    if (_activity!.currentParticipants! < _activity!.maxParticipants!) {
                      var res = await NetRequester.request(Apis.registerActivity(_activity!.activityId!));
                      if (res['code'] == '1') {
                        Toast.popToast('报名成功');
                        setState(() {
                          _activity!
                            ..currentParticipants = _activity!.currentParticipants! + 1
                            ..isRegistered = 1; // 增加状态更新
                        });
                      } else {
                        Toast.popToast('报名失败');
                      }
                    } else {
                      Toast.popToast('报名人数已满');
                    }
                  }
                },
                child: Center(
                  child: Text(_activity!.isRegistered == 1 ? '取消报名' : '我要报名'),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
                SizedBox(width: 10.w),
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
}
