import 'package:carousel_slider/carousel_slider.dart';
import 'package:client/core/net/net.dart';
import 'package:client/widget/my_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '../../core/list_repository/goods_repo.dart';
import '../../core/list_repository/user_repo.dart';
import '../../core/model/goods.dart';
import '../../core/model/theme_model.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net_request.dart';
import '../../util/toast.dart';
import '../../widget/image_build.dart';

class GoodsDetailPage extends StatefulWidget {
  final int goodsId;
  const GoodsDetailPage({super.key, required this.goodsId});

  @override
  State<GoodsDetailPage> createState() => _GoodsDetailPageState();
}

class _GoodsDetailPageState extends State<GoodsDetailPage> with TickerProviderStateMixin {
  var _future;
  late Goods _goods;
  late TabController _tabController;
  late PageController _pageController;
  final ScrollController _scrollController=ScrollController();
  late UserRepository _userRepository;
  late GoodsRepository _goodsRepository;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _pageController = PageController();
    _future = _getGoods();
  }
  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
  }

  Future<void> _getGoods() async{
    var res = await NetRequester.request(Apis.getGoodsByGoodsId(widget.goodsId));
      if (res['code'] == '1'&& res['data'] != null) {
        _goods = Goods.fromJson(res['data']);
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
      body:const Text('123'),
    );
  }
  Widget _buildInputBar() {
    return Container();
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
    //这里我不想要TapBar，想要一个容器，左边写着评论
    return SliverToBoxAdapter(
      child: StickyHeader(
        header: Consumer<ThemeModel>(
          builder: (BuildContext context, themeModel, _) {
            return TabBar(
              controller: _tabController,
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
              tabs: const <Widget>[
                Tab(text: '评论'),
              ],
            );
          },
        ),
        content: SizedBox(
          child: Column(
            children: [
              // Text('评论'),
              _buildImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goodsInfo() {
    return SliverToBoxAdapter(
      child: _buildImage(),
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
    String baseUrl = "${NetConfig.ip}/images/";

    return CarouselSlider(
      options: CarouselOptions(
        height: 300.w,
        enlargeCenterPage: true, // 居中放大
        viewportFraction: 1, // 视图占比
        enableInfiniteScroll: false, // 禁用无限滚动
      ),
      items: images.map((img) {
        String imageUrl = "$baseUrl/$img";

        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(imageUrl: imageUrl),
                  ),
                );
              },
              child: Hero(
                tag: imageUrl, // 共享的 Hero 动画标签
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text("加载失败"));
                  },
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

}



class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: imageUrl, // 共享的 Hero 动画标签
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text("加载失败", style: TextStyle(color: Colors.white)));
              },
            ),
          ),
        ),
      ),
    );
  }
}
