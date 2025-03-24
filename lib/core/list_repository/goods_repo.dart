import 'package:client/core/net/net_request.dart';
import 'package:flutter/foundation.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../util/toast.dart';
import '../model/goods.dart';
import '../net/my_api.dart';

class GoodsRepository  extends LoadingMoreBase<Goods>{
  int pageIndex = 1;
  bool _hasMore = true;
  bool forceRefresh = false;
  int userId;

  int type;
  String? key;
  GoodsRepository(this.userId, this.type, [this.key]);
  @override
  bool get hasMore => _hasMore || forceRefresh;
  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async{
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
//searchGoods
//
  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    String url = '';
    switch (type) {
      case 1:
        url=Apis.getResaleList(pageIndex);
        break;
      case 2:
        url=Apis.getBuyList(pageIndex);
        break;
      case 3:
        url=Apis.getMyResaleList(pageIndex);
        break;
      case 4:
        url=Apis.getBuyList(pageIndex);
        break;
      case 5:
        url=Apis.getCollectedGoodsByUserId(userId, pageIndex);
        break;
      case 6:
        url=Apis.searchGoods(key!, pageIndex);
        break;
      default:
        throw Exception('Unsupported goods type : $type');
    }
    bool isSuccess = false;
    try{
      Map result = await NetRequester.request(url);
      if(result.containsKey('data')){
        if(pageIndex==1){
          clear();
        }
        List source = result['data'];
        if(source.isNotEmpty){
          for(var item in source){
            var goods = Goods.fromJson(item);
            if(!contains(goods)&&hasMore)add(goods);
          }
        }
        _hasMore = pageIndex < result['totalPage'];
        pageIndex++;
        isSuccess = true;
      }
    }catch(exception,stack){
      isSuccess = false;
      if(kDebugMode){
        print(exception);
      }
      if(kDebugMode){
        print(stack.toString());
      }
    }
    return isSuccess;
  }

}