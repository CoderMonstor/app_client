import 'package:client/widget/my_card/user_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../core/global.dart';
import '../../core/list_repository/user_repo.dart';
import '../../core/model/user.dart';
import '../../widget/build_indicator.dart';

class CommonUserPage extends StatefulWidget{

  final String? str;

  const CommonUserPage({super.key, this.str});

  @override
  State<StatefulWidget> createState() {
    return _CommonUserPageState();
  }
}

class _CommonUserPageState extends State<CommonUserPage> {

  late UserRepository _userRepository;
  @override
  void initState() {
    super.initState();
    _userRepository =  UserRepository(Global.profile.user?.userId,4,widget.str!);
  }

  @override
  void dispose() {
    _userRepository.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _userRepository.refresh,
        child: LoadingMoreList(
          ListConfig<User>(
            itemBuilder: (BuildContext context, User user, int index){
              return UserCard(user: user,list: _userRepository,index: index);
            },
            sourceList: _userRepository,
            indicatorBuilder: _buildIndicator,
          ),
        ),
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _userRepository);
  }
}