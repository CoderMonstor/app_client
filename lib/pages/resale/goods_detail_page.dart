import 'package:client/core/model/goods_comment.dart';
import 'package:client/core/my_color.dart';
import 'package:client/core/net/net.dart';
import 'package:client/pages/resale/resale_common_dialog.dart';
import 'package:client/pages/user/profile_page.dart';
import 'package:client/widget/item_builder_goods.dart';
import 'package:client/widget/my_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:loading_more_list/loading_more_list.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../core/global.dart';
import '../../core/list_repository/goods_comment_repo.dart';
import '../../core/model/goods.dart';
import '../../core/model/theme_model.dart';
import '../../core/model/user.dart';
import '../../core/model/user_model.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../util/toast.dart';
import '../../widget/build_indicator.dart';
import '../../widget/image_build.dart';
import '../chat/chat_page.dart';

class GoodsDetailPage extends StatefulWidget {
  final int goodsId;
  const GoodsDetailPage({super.key, required this.goodsId});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> with TickerProviderStateMixin {
  var _future;
  late Goods _goods;
  late User _user;
// 默认是微信支付
  late TabController _tabController;
  late GoodsCommentRepository _goodsCommentRepository;
  final ScrollController _scrollController=ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _future = _initial();
  }
  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

  Future<void> _initial() async{
    var resGoods = await NetRequester.request(Apis.getGoodsByGoodsId(widget.goodsId));
    _goodsCommentRepository = GoodsCommentRepository(widget.goodsId);
      if (resGoods['code'] == '1'&& resGoods['data'] != null) {
        _goods = Goods.fromJson(resGoods['data']);
        var resUser = await NetRequester.request(Apis.findUserById(_goods.userId!));
        if (resUser['code'] == '1'&& resUser['data'] != null) {
          _user = User.fromJson(resUser['data']);
        }
      }else{
        Toast.popToast('内容已经不在了');
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(context).pop();
        });
        throw '内容已经不在了';
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasError){
              return Center(
                child: Text(
                    '加载失败，请重试',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(48),
                    ),
                ),
              );
            }
            else{
              return Stack(
                children:<Widget> [
                  _buildBody(),
                  _buildInputBar()
                ],
              );
            }
          }else{
            return Center(
              child: SpinKitRing(
                lineWidth: 3,
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        },
      ),
    );
  }
  Widget _buildBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var pinnedHeaderHeight = statusBarHeight + kToolbarHeight + 120.w;
    return extended.ExtendedNestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: _headerSliverBuilder,
      pinnedHeaderSliverHeightBuilder: (){
        return pinnedHeaderHeight;
      },
      body:LoadingMoreList(
        ListConfig<GoodsComment>(
          itemBuilder: (BuildContext context, GoodsComment comment, int index) {
            return ItemBuilderGoods.buildGoodsComment(context, comment, _goodsCommentRepository, index);
          },
          sourceList: _goodsCommentRepository,
          indicatorBuilder: _buildIndicator,
          lastChildLayoutType: LastChildLayoutType.none,
          // padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90))
        ),
      ),
    );
  }

  List<Widget> _headerSliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      const SliverAppBar(
        pinned: true,
        title: Text('商品详情'),
      ),
      _goodsInfo(),
      _tabBar()
    ];
  }

  Widget _tabBar() {
    return SliverToBoxAdapter(
      child: StickyHeader(
        header: Consumer<ThemeModel>(
          builder: (BuildContext context, themeModel, _) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '评论',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        content:const SizedBox(),
      ),
    );
  }
  Widget _goodsInfo() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildImage(),
          _buildUserInfo(),
          _buildSingleRow('商品名称'),
          _buildNameAndPrice(),
          _buildSingleRow('描述'),
          _buildDesc(),
          _buildSingleRow('交易流程'),
          _buildExchangeWay(),
        ],
      ),
    );
  }
  Widget _buildUserInfo() {
    return MyListTile(
      top: 10,
      bottom: 10,
      right: 32,
      leading: Container(
        padding: const EdgeInsets.only(left: 32.0 , right: 32.0),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: _user.userId!),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30.0,
                backgroundImage: NetworkImage('${NetConfig.ip}/images/${_user.avatarUrl!}'),
              ),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_user.username}',
                ),
                Text(
                  '${_user.fanNum} 粉丝 ${_user.followNum} 关注',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ]
            )
          ]
        )
      ),
      trailing: TextButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.grey; // 按下时的颜色
                  }
                  return _user.isFollow == 1
                      ? Colors.white54
                      : MyColor.color_gray_light;
                }),
          ),
          onPressed: () async {
            var fanId = Global.profile.user!.userId;
            var res = await NetRequester.request(
                _user.isFollow == 0
                    ? Apis.followAUser(fanId!, _user.userId!)
                    : Apis.cancelFollowAUser(fanId!, _user.userId!));
            if (res['code'] == '1') {
              setState(() {
                _user.isFollow = _user.isFollow == 1 ? 0 : 1;
              });
              _user.isFollow == 1
                  ? Global.profile.user!.followNum! +  1
                  : Global.profile.user!.followNum! -  1;
              final userModel = Provider.of<UserModel>(context, listen: false);
              userModel.updateUser(Global.profile.user!);
              UserModel().notifyListeners();
            }
          },
          child: Text(_user.isFollow == 1 ? '已关注' : '关注',
              style: const TextStyle(color:Colors.grey))
      ),
    );
  }
  Widget _buildDesc() {
    return Container(
      padding: const EdgeInsets.only(left: 32.0 , right: 32.0),
      alignment: Alignment.centerLeft,
      child: Text(
        '${_goods.goodsDesc}',
        style: const TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }
  Widget _buildNameAndPrice() {
    return Container(
      padding: const EdgeInsets.only(left: 32.0 , right: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_goods.goodsName}',
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
          Text(
            '￥${_goods.goodsPrice}',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ]
      )
    );
   }
  Widget _buildExchangeWay() {
    return Container(
      padding: const EdgeInsets.only(left: 40.0, right: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _simpleExchange('发布信息'),
          //一根横线
          _buildLine(),
          _simpleExchange('买卖沟通'),
          //一根横线
          _buildLine(),
          _simpleExchange('当面交易'),
          //一根横线
          _buildLine(),
          _simpleExchange('交易完成'),
        ],
      ),
    );
  }
  Widget _buildLine() {
    return Expanded( // 横线占据剩余空间
      child: Container(
        height: 1.0,
        color: Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
      ),
    );
  }
  Widget _simpleExchange(String str){
    return Column(
      children: [
        Container(
          width: 35.w,
          height: 35.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.w),
            color: Colors.pink,
          ),
          alignment: Alignment.center,
          child: Text(
            '√',
            style: TextStyle(
              fontSize: 18.w,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8.w),
        Text(str),
      ],
    );
  }
  Widget _buildImage() {
    if (_goods.image == null || _goods.image!.isEmpty) {
      return Container(
        height: 300.w,
        alignment: Alignment.center,
        child: const Text('暂无图片'),
      );
    }
    List<String> images = _goods.image!.split('￥'); // 解析图片路径列表
    print(images);
    return ImageBuild.carouselImages(context, _goods.goodsId!, images);
  }
  Widget _buildSingleRow(String str) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,  
        children: [
          Container(
            width: ScreenUtil().setWidth(10),  // 增加宽度
            height: ScreenUtil().setHeight(30),  // 设置明确的高度
            decoration: const BoxDecoration(
              color: Colors.pink,
              border: Border(
                right: BorderSide(
                  color: Colors.grey,
                  width: 2.0,  // 减小边框宽度
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),  // 添加一些间距
          Text(
            str,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _goodsCommentRepository);
  }
  _buildInputBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ResaleCommentDialog(
                            goodsId: _goods.goodsId!,
                            list: _goodsCommentRepository,
                          );
                        }
                    );
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                    ),
                  ),
                  child: Text(
                    "说点什么吧……",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 42,
              width: 50,
              child: TextButton(
                onPressed: () async {
                  try {
                    final isCollect = _goods.isCollected != 1;
                    final api = isCollect ? Apis.collectGoods : Apis.cancelCollectGoods;
                    final response = await NetRequester.request(api(widget.goodsId));
                    if (response['code'] == '1') {
                      setState(() {
                        _goods.isCollected = isCollect ? 1 : 0;
                      });
                      Toast.popToast(isCollect ? '收藏成功' : '取消收藏');
                    }
                  } catch (e){
                    Toast.popToast('收藏失败');
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory, // 取消水波纹
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _goods.isCollected == 1 ? Icons.star : Icons.star_border,
                      size: 20,
                    ),
                    const Text(
                      '收藏',
                      style: TextStyle(fontSize: 12), // 调小字体
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  if(Global.profile.user?.userId != _goods.userId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(user: _user),
                      ),
                    );
                  } else {
                    Toast.popToast('这是你的商品欸');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat,
                      size: 20,
                    ),
                    Text(
                      '私聊',
                      style: TextStyle(fontSize: 12), // 调小字体
                    ),
                  ],
                ),
              ),
            ),
            if(_goods.type==GoodsType.idle)
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  if(Global.profile.user?.userId != _goods.userId) {
                    // 唤起底部弹窗
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        return PurchaseFormWidget(
                          goods: _goods,
                          onPaymentChanged: (selectedPayment) {
                            setState(() {
                            });
                          },
                        );
                      },
                    );

                  } else {
                    Toast.popToast('这是你的商品欸');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('立即购买'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class PurchaseFormWidget extends StatefulWidget {
  final Goods goods;
  final Function(String selectedPayment) onPaymentChanged;
  const PurchaseFormWidget({super.key, required this.goods, required this.onPaymentChanged});

  @override
  _PurchaseFormWidgetState createState() => _PurchaseFormWidgetState();
}

class _PurchaseFormWidgetState extends State<PurchaseFormWidget> {
  String _selectedPayment = 'wechat';
  static const _paymentMethods = [
    {'title': '微信支付', 'value': 'wechat'},
    {'title': '支付宝', 'value': 'alipay'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品信息头
          Row(
            children: [
              Image.network(
                '${NetConfig.ip}${widget.goods.image?.split('￥').first ?? ''}',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goods.goodsName ?? '未知商品',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '单价：￥${widget.goods.goodsPrice}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          // 费用明细
          Column(
            children: [
              _buildPriceRow('商品金额', '￥${(widget.goods.goodsPrice!).toStringAsFixed(2)}'),
              _buildPriceRow(
                '实付款',
                '￥${_calculateTotalPrice()}',
                isBold: true,
              ),
            ],
          ),
          const Divider(height: 30),
          // 付款方式
          const Text(
            '选择付款方式：',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          ..._paymentMethods.map((method) => RadioListTile<String>(
            value: method['value']!,
            groupValue: _selectedPayment,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/${method['value']}.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 10),
                Text(method['title']!),
              ],
            ),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedPayment = value;
                // 通知父 widget 改变支付方式
                widget.onPaymentChanged(_selectedPayment);
              });
            },
          )),
          // 底部确认栏
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: '合计：',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextSpan(
                        text: '￥${widget.goods.goodsPrice?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handlePurchase();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '确认支付',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal
          )),
          Text(value, style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.red : Colors.black,
          )),
        ],
      ),
    );
  }
  String _calculateTotalPrice() {
    return (widget.goods.goodsPrice!).toStringAsFixed(2);
  }

  void _handlePurchase() async{
    if(widget.goods.sellStatus=='0'){
      var result = await NetRequester.request(Apis.addOrder(widget.goods.goodsId!, Global.profile.user!.userId!));
      if(result['code']=='1'){
        Toast.popToast('下单成功');
        Navigator.of(context).pop();
      }else{
        Toast.popToast('下单失败');
      }
    }
  }
}


