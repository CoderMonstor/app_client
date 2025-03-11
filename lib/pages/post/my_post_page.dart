//有点没用

import 'package:client/util/app_bar/my_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/post_repo.dart';
import '../../core/model/post.dart';
import '../../widget/build_indicator.dart';
import '../../widget/my_card/post_card.dart';

class MyPostPage extends StatefulWidget{
  const MyPostPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyPostPageState();
  }
}

class _MyPostPageState extends State<MyPostPage> {

  late PostRepository _postRepository;
  @override
  void initState() {
    super.initState();
    _postRepository =  PostRepository(Global.profile.user!.userId!,1);
  }

  @override
  void dispose() {
    _postRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.simpleAppbar('我的动态'),
      body: RefreshIndicator(
        onRefresh: _postRepository.refresh,
        child: LoadingMoreList(
          ListConfig<Post>(
            itemBuilder: (BuildContext context, Post item, int index){
              return PostCard(post: item,list: _postRepository,index: index);
            },
            sourceList: _postRepository,
            indicatorBuilder: _buildIndicator,
            padding: EdgeInsets.only(
                top:ScreenUtil().setWidth(20),
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20)
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _postRepository);
  }
}