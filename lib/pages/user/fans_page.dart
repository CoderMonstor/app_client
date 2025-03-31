import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/user_repo.dart';
import '../../core/model/user.dart';
import '../../util/app_bar/my_app_bar.dart';
import '../../widget/build_indicator.dart';
import '../../widget/my_card/user_card.dart';

class FansPage extends StatefulWidget{
  const FansPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FansPageState();
  }
}

class _FansPageState extends State<FansPage> {

  late UserRepository _userRepository;
  @override
  void initState() {
    super.initState();
    _userRepository =  UserRepository(Global.profile.user?.userId,1);
  }

  @override
  void dispose() {
    _userRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar.simpleAppbar('我的粉丝'),
      body: LoadingMoreList(
        ListConfig<User>(
          itemBuilder: (BuildContext context, User user, int index){
            return UserCard(user: user,list: _userRepository,index: index,showConnect: true,);
          },
          sourceList: _userRepository,
          indicatorBuilder: _buildIndicator,
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _userRepository);
  }
}