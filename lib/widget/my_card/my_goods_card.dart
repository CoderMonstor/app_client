import 'package:client/core/net/net.dart';
import 'package:client/pages/resale/goods_detail_page.dart';
import 'package:client/widget/my_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/global.dart';
import '../../core/model/goods.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../pages/resale/edit_goods.dart';
import '../../util/toast.dart';
import '../dialog_build.dart';
class MyGoodsCard extends StatefulWidget {
  final Goods goods;
  const MyGoodsCard({super.key, required this.goods});

  @override
  State<MyGoodsCard> createState() => _MyGoodsCardState();
}

class _MyGoodsCardState extends State<MyGoodsCard> {
  String _getImageUrl() {
    final imagePath = widget.goods.image?.split('￥').first ?? '';
    return '${NetConfig.ip}$imagePath';
  }
  @override
  Widget build(BuildContext context) {
    return MyListTile(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context)=>GoodsDetailPage(goodsId: widget.goods.goodsId!)));
      },
      bottom: 20.h,
      leading: Stack(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: NetworkImage(_getImageUrl()),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (widget.goods.sellStatus=='1')
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.r),
                    bottomRight: Radius.circular(8.r),
                  ),
                ),
                child: Text(
                  '已售',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      center: Column(
        children: [
          Row(
            children: [
              SizedBox(width:15.w),
              SizedBox(
                width: 200.w,
                child: SizedBox(
                  child: Text(widget.goods.goodsName ?? '未命名商品',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),

                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              SizedBox(width: 15.w),
              SizedBox(
                width: 200.w,
                child: Text(widget.goods.goodsDesc!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if(widget.goods.userId==Global.profile.user!.userId)
          Row(
            children: [
              Offstage(
                offstage: widget.goods.type=='1',
                child:widget.goods.status=='0'?
                TextButton(onPressed: () async{
                  var res=await NetRequester.request(Apis.updateSaleOrNot(widget.goods.goodsId!));
                  if(res['code'] == '1'){
                    setState(() {
                      widget.goods.status='1';
                    });
                  }
                  }, child: const Text('下架')):
                TextButton(onPressed: ()async{
                  var res=await NetRequester.request(Apis.updateSaleOrNot(widget.goods.goodsId!));
                  if(res['code'] == '1'){
                    setState(() {
                      widget.goods.status='0';
                    });
                  }
                }, child: const Text('上架')),
              ),
              TextButton(onPressed: ()async{
                var res=await NetRequester.request(Apis.deleteGoods(widget.goods.goodsId!));
                if(res['code'] == '1'){
                  Toast.popToast('已删除');
                }
              }, child: const Text('删除')),
              TextButton(onPressed: () async{
                Navigator.push(context, CupertinoPageRoute(builder: (context)=>EditGoods(goodsId: widget.goods.goodsId!)));
                }, child: const Text('编辑')),
            ],
          )
        ],
      ),
      trailing: _buildSellOrNot(),
      );
  }
  Widget _buildSellOrNot(){
    return Container(
      decoration: BoxDecoration(
        color: widget.goods.type == '0' ? const Color(0xFF2196F3) : const Color(0xFFFF9800), // 深蓝色和橙色
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          widget.goods.type == '0' ? '闲置' : '求购',
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white // 添加文字颜色确保可读性
          ),
        ),
      ),
    );
  }
}
