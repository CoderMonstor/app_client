import 'package:flutter/cupertino.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../model/discuss.dart';
import '../net/my_api.dart';
import '../net/net_request.dart';

class DiscussRepo extends LoadingMoreBase<Discuss> {
  int pageIndex=1;
  bool _hasMore=true;
  bool forceRefresh=false;
  int activityId;
  DiscussRepo(this.activityId);

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) {
    _hasMore = true;
    pageIndex = 1;
    forceRefresh = !notifyStateChanged;
    var result = super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async{
    bool isSuccess = false;
    try{
      var result = await NetRequester.request(Apis.getDiscussByActivityId(activityId, pageIndex));
      if(result.containsKey("data")){
        if(pageIndex==1){
          clear();
        }
        List source = result["data"];
        for(var item in source){
          var discuss = Discuss.fromJson(item);
          if(!contains(discuss)&&hasMore)add(discuss);
        }
        _hasMore=pageIndex<result["totalPage"];
        pageIndex++;
        isSuccess = true;
      }
    }catch(exception,stack){
      isSuccess = false;
      debugPrint(exception.toString());
      debugPrint(stack.toString());
    }
    return isSuccess;
  }

}