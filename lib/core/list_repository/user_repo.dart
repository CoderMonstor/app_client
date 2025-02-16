import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../model/user.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class UserRepository extends LoadingMoreBase<User> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  int? id;
  //1:查粉丝2：查关注3:点赞记录
  int? type;
  String key;
  UserRepository(this.id, this.type, [this.key = '']) : super();


  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    pageIndex = 1;
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    bool isSuccess = false;
    String url;
    switch (type){
      case 1:
        url = Apis.findFan(id!,pageIndex);
        break;
      case 2:
        url = Apis.findFollow(id!,pageIndex);
        break;
      case 3:
        url = Apis.getLikedUser(id!,pageIndex);
        break;
      case 4:
        url = Apis.searchUser(pageIndex,key);
        break;
      default:
        url = ''; // 添加默认分支以确保 url 被赋值
        if (kDebugMode) {
          print('Unknown type: $type');
        }
    }
    try {
      var result = await NetRequester.request(url);
      if(result.containsKey('data')){
        if (pageIndex == 1) {
          clear();
        }
        List source = result['data'] ?? [];
        for (var item in source) {
          var user = User.fromJson(item);
          if (!contains(user) && hasMore) add(user);
        }
        _hasMore = pageIndex < result['totalPage'];
        pageIndex++;
        isSuccess = true;
      }
    } catch (exception, stack) {
      isSuccess = false;
      print(exception);
      print(stack.toString());
    }
    return isSuccess;
  }
}