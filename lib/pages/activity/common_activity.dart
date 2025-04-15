import 'package:client/core/list_repository/activity_repo.dart';
import 'package:client/core/model/activity.dart';
import 'package:client/widget/my_card/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../widget/build_indicator.dart';

class CommonActivity extends StatefulWidget {
  final int? userId;
  final int? type;
  final String? str;
  final String? orderBy;
  const CommonActivity({super.key, this.type, this.str, this.orderBy,  this.userId});
  @override
  State<StatefulWidget> createState() {
    return _CommonActivityState();
  }
}

class _CommonActivityState extends State<CommonActivity> {
  late ActivityRepository _activityRepository;
  @override
  void initState() {
    super.initState();
    _activityRepository =  ActivityRepository(widget.userId!, widget.type!,widget.str,widget.orderBy);
  }

  @override
  void dispose() {
    _activityRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _activityRepository.refresh,
        child: LoadingMoreList(
          ListConfig<Activity>(
            itemBuilder: (BuildContext context, Activity item, int index){
              // return PostCard(post: item,list: _postRepository,index: index);
              return ActivityCard(activity: item);
            },
            sourceList: _activityRepository,
            indicatorBuilder: _buildIndicator,

          ),
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _activityRepository);
  }
}
