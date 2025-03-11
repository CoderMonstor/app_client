import 'package:client/widget/my_card/user_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../core/global.dart';
import '../core/list_repository/user_repo.dart';
import '../core/model/user.dart';
import '../util/app_bar/my_app_bar.dart';
import '../widget/build_indicator.dart';

class FollowPage extends StatefulWidget{
  const FollowPage({super.key});

  @override
  State<StatefulWidget> createState() => _FollowPageState();

}

class _FollowPageState extends State<FollowPage> {
  late UserRepository _userRepository;
  @override
  void initState() {
    super.initState();
    _userRepository =  UserRepository(Global.profile.user?.userId,2);
  }

  @override
  void dispose() {
    _userRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.simpleAppbar('我的关注'),
      body: LoadingMoreList(
        ListConfig<User>(
          itemBuilder: (BuildContext context, User user, int index){
            return UserCard(user: user,list: _userRepository,index: index);
          },
          sourceList: _userRepository,
          indicatorBuilder: _buildIndicator,


          // lastChildLayoutType: LastChildLayoutType.none,
          // padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90)),
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _userRepository);
  }
}