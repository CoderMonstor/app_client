import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../util/toast.dart';
import '../model/activity.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class ActivityRepo extends LoadingMoreBase<Activity> {
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  int userId;
  int type;
  String? key;
  String? orderBy;
  ActivityRepo(this.userId ,this.type, [this.key, this.orderBy]);

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    pageIndex = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    if(result){
      Toast.popToast('刷新成功');
    }
    forceRefresh = false;
    return result;
  }
  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    String url = '';
    switch (type) {
      case 1:
        url = Apis.getAllActivities(userId, pageIndex);
        break;
       case 2:
        url = Apis.getMyActivities(userId, pageIndex);
        break;
      case 3:
        url = Apis.getMyStarActivities(userId, pageIndex);
        break;
      case 4:
        url = Apis.searchActivity(key!, pageIndex);
        break;

      default:
        throw Exception("Unsupported post type: $type"); // 添加默认处理
    }
    bool isSuccess = false;
    try {
      Map result = await NetRequester.request(url);
      if (result.containsKey('data')) {
        if (pageIndex == 1) {
          clear();
        }
        List source = result['data'];
        if (source.isNotEmpty) {
          for (var item in source) {
            var activity = Activity.fromJson(item);
            if (!contains(activity) && hasMore) add(activity);
          }
        }
        _hasMore = pageIndex < result['totalPage'];
        pageIndex++;
        isSuccess = true;
      }
    }catch (exception, stack) {
      isSuccess = false;
      if (kDebugMode) {
        print(exception);
      }
      if (kDebugMode) {
        print(stack.toString());
      }
    }
    return isSuccess;
  }
}

