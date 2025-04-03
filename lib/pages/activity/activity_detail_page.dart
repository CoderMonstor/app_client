import 'dart:math';

import 'package:client/core/list_repository/discuss_repo.dart';
import 'package:client/core/model/activity.dart';
import 'package:client/core/net/my_api.dart';
import 'package:client/core/net/net.dart';
import 'package:client/core/net/net_request.dart';
import 'package:client/util/build_date.dart';
import 'package:client/widget/image_build.dart';
import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/model/discuss.dart';

class ActivityDetailPage extends StatefulWidget {
  final int? activityId;
  const ActivityDetailPage({super.key, required this.activityId});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late DiscussRepo _discussRepo;
  late Future<void> _initialActivity;
  Activity? _activity;

  @override
  void initState() {
    super.initState();
    _initialActivity = _getActivity();
  }

  @override
  void dispose() {
    super.dispose();
    _discussRepo.dispose();
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
            body: Stack(
              children: [
                _buildBody(),
                _buildInputBar(),
              ],
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
    return extended.ExtendedNestedScrollView(
      headerSliverBuilder: _headerSliverBuilder,
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      body: Container(
        color: Colors.grey[200],
        child: LoadingMoreList(
          ListConfig<Discuss>(
            padding: EdgeInsets.only(top: 10.w),
            sourceList: _discussRepo,
            itemBuilder: (context, item, index) => _buildCommentItem(context, item),
          ),
        )
      ),
    );
  }
  Widget _buildCommentItem(BuildContext context, Discuss item) {
    return Container(
      margin: EdgeInsets.only(
        // left: 20.0 * item.depth, // 根据层级缩进
        top: 8.w,
        bottom: 8.w,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              CircleAvatar(
                radius: 20.w,
                backgroundImage: NetworkImage('${NetConfig.ip}/images/${item.avatarUrl}' ?? ''),
              ),
              SizedBox(width: 10.w),
              Text(item.username ?? ''),
            ],
          ),
          SizedBox(height: 10.w),
          Text(item.content ?? ''),
        ],
      ),
    );
  }
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
              TextButton(onPressed: (){}, child: const Center(child: Text('我要报名'))),
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
      child: Container(
        height: 50.w,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '发表评论...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.w)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blueAccent, size: 28.w),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
