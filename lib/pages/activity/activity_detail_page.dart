import 'dart:math';

import 'package:client/core/model/activity.dart';
import 'package:client/core/net/my_api.dart';
import 'package:client/core/net/net_request.dart';
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
  late Future<Activity?> _initialActivity;
  Activity? activity;

  @override
  void initState() {
    super.initState();
    _initialActivity = _getActivity();
  }

  Future<Activity?> _getActivity() async {
    try {
      var response = await NetRequester.request(Apis.getActivityDetails(widget.activityId!));
      if (response['code'] == '1') {
        return Activity.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Error fetching activity: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Activity?>(
        future: _initialActivity,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitRing(
                lineWidth: 3,
                color: Theme.of(context).primaryColor,
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('请求错误'));
          } else {
            activity = snapshot.data;
            return Stack(
              children: [
                _buildBody(),
                _buildInputBar(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var pinnedHeaderHeight = statusBarHeight + kToolbarHeight + 120.w;

    return extended.ExtendedNestedScrollView(
      headerSliverBuilder: _headerSliverBuilder,
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView(
          children: [
            _activityInfo(),
            // _activityInfo(),
            // _activityInfo(),
            // _activityInfo(),
          ],
        ),
      ),
    );
  }

  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        pinned: true,
        expandedHeight: 200.w,
        flexibleSpace: FlexibleSpaceBar(
          // title: const Text('活动详情'),
          background: Image.asset(
            'assets/images/back.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];
  }

  Widget _activityInfo() {
    return Card(
      margin: EdgeInsets.only(top: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('活动名称', activity?.activityName),
            _buildDetailItem('活动内容', activity?.details),
            _buildDetailItem('活动时间', activity?.activityTime),
            _buildDetailItem('活动地点', activity?.location),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(value ?? '暂无信息', style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '发表评论...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {
                // 发送评论逻辑
              },
            ),
          ],
        ),
      ),
    );
  }
}
