/*
公共动态页面
type 1:动态 2:关注 3:评论 4:回复
str 搜索内容
orderBy hot:热门 postId:最新
*/
import 'package:client/core/model/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/post_repo.dart';
import '../../core/model/post.dart';
import '../../core/model/user.dart';
import '../../widget/build_indicator.dart';
import '../../widget/post_card.dart';

class CommonPostPage extends StatefulWidget {
  final int? type;
  final String? str;
  final String? orderBy;
  const CommonPostPage({super.key, this.type, this.str, this.orderBy});
  @override
  State<StatefulWidget> createState() {
    return _CommonPostPageState();
  }
}

class _CommonPostPageState extends State<CommonPostPage> {
  late PostRepository _postRepository;
  // @override
  // void initState() {
  //   super.initState();
  //   _postRepository =  PostRepository(Global.profile.user!.userId!, widget.type!,widget.str,widget.orderBy);
  // }
  @override
  void initState() {
    super.initState();

    // 确保 Global.profile.user 不为 null
    final user = Global.profile.user ?? User.none();

    // 使用空值合并运算符提供默认值
    final type = widget.type ?? 1;
    final str = widget.str ?? '';
    final orderBy = widget.orderBy ?? 'hot';

    _postRepository = PostRepository(user.userId!, type, str, orderBy);
  }

  @override
  void dispose() {
    _postRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingMoreList(
        ListConfig<Post>(
          itemBuilder: (BuildContext context, Post item, int index){
            return Card(
              margin: EdgeInsets.only(
                top: ScreenUtil().setWidth(20),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                ),
              ),
            );
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
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _postRepository);
  }
}
