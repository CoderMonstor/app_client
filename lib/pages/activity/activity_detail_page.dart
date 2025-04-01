import 'package:client/core/model/activity.dart';
import 'package:client/core/net/my_api.dart';
import 'package:client/core/net/net_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class ActivityDetailPage extends StatefulWidget {
  final int? activityId;
  const ActivityDetailPage({super.key, required this.activityId});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  var _initialActivity;
  Activity? activity;
  @override
  void initState() {
    super.initState();
    _initialActivity=_getActivity();
  }
  Future<void> _getActivity() async{
    print('this function has been generation');
    var res=await NetRequester.request(Apis.getActivityDetails(widget.activityId!));
    if(res['code']=='1'){
      activity=Activity.fromJson(res['data']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialActivity,
        builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            if(snapshot.hasError){
              print(snapshot.error);
              return const Center(child: Text('请求错误'),);
            }else{
              return Stack(
                children: [
                  _buildBody(),
                  _buildInputBar(),
                ],
              );
            }
          }else{
            return Center(
              child: SpinKitRing(
                lineWidth: 3,
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        }
    );
  }
  Widget _buildBody(){
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var pinnedHeaderHeight = statusBarHeight + kToolbarHeight + 120.w;
    return extended.ExtendedNestedScrollView(
        headerSliverBuilder: _headerSliverBuilder,
        pinnedHeaderSliverHeightBuilder: () {
      return pinnedHeaderHeight;
    },
      body: Container(
      height: 300,
      color: Colors.red,
      ),
    );
  }
  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      const SliverAppBar(
        pinned: true,
        title: Text('动态'),
      ),
      _activityInfo(),
    ];
  }
  Widget _activityInfo(){
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        color: Colors.red[600],
      ),
    );
  }
  Widget _buildInputBar(){
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        color: Colors.black54,
      ),
    );
  }
}
