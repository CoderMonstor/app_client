/*
动态详情页面
 */

import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;

import '../../core/list_repository/comment_repo.dart';
import '../../core/list_repository/post_repo.dart';
import '../../core/list_repository/user_repo.dart';
import '../../core/maps.dart';
import '../../core/model/comment.dart';
import '../../core/model/post.dart';
import '../../core/model/user.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net.dart';
import '../../core/net/net_request.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/toast.dart';
import '../../widget/build_indicator.dart';
import '../../widget/item_builder.dart';


class PostDetailPage extends StatefulWidget {

  final int? offset;
  final int? postId;
  const PostDetailPage({super.key, this.offset, this.postId});

  @override
  State<StatefulWidget> createState() {
    return _PostDetailPageState();
  }
}

class _PostDetailPageState extends State<PostDetailPage> with TickerProviderStateMixin {
  String textSend = '';
  var _future;
  late Post _post;
  late TabController _tabController;
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _gridController = ScrollController();
  late UserRepository _userRepository;
  late PostRepository _postRepository;
  late CommentRepository _commentRepository;
  @override
  void initState() {
    _future = _getPost();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _pageController = PageController(initialPage: 1);
    super.initState();
  }

  @override
  void dispose() {
    _userRepository.dispose();
    _commentRepository.dispose();
    _postRepository.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getPost() async {
    var res = await NetRequester.request(Apis.getPostByPostId(widget.postId!));
    if (res['code'] == '1' && res['data'] != null) {
      _post = Post.fromJson(res['data']);
      _userRepository = UserRepository(_post.postId, 3);
      _postRepository = PostRepository(_post.postId, 4);
      _commentRepository = CommentRepository(_post.postId);
    } else {
      Toast.popToast('内容已经不在了');
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      throw '内容已经不在了';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            if (snap.hasError) {
              return Center(
                child: Text('加载失败，请重试',
                    style: TextStyle(fontSize: ScreenUtil().setSp(48))),
              );
            } else {
              return Stack(
                children: <Widget>[_buildBody(), _buildInputBar()],
              );
            }
          } else {
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
        pinnedHeaderSliverHeightBuilder: () {
          return pinnedHeaderHeight;
        },
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            LoadingMoreList(
              ListConfig<User>(
                  itemBuilder: (BuildContext context, User user, int index) {
                    return ItemBuilder.buildUserRow(context, user, 3);
                  },
                  sourceList: _userRepository,
                  indicatorBuilder: _buildIndicator,
                  lastChildLayoutType: LastChildLayoutType.none,
                  padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90))),
            ),
            LoadingMoreList(
              ListConfig<Comment>(
                  itemBuilder:
                      (BuildContext context, Comment comment, int index) {
                    return ItemBuilder.buildComment(
                        context, comment, _commentRepository, index);
                  },
                  sourceList: _commentRepository,
                  indicatorBuilder: _buildIndicator,
                  lastChildLayoutType: LastChildLayoutType.none,
                  padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90))),
            ),
            LoadingMoreList(
              ListConfig<Post>(
                  itemBuilder: (BuildContext context, Post post, int index) {
                    return ItemBuilder.buildForwardRow(context, post);
                  },
                  sourceList: _postRepository,
                  indicatorBuilder: _buildIndicator,
                  lastChildLayoutType: LastChildLayoutType.none,
                  padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90))),
            ),
          ],
        ));
  }

  List<Widget> _headerSliverBuilder(
      BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      const SliverAppBar(
        pinned: true,
        elevation: 0,
        title: Text('动态'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(-8),
          child: SizedBox(),
        ),
      ),
      _postInfo(),
      _content(),
      SliverToBoxAdapter(child: SizedBox(height: 20.w)),
      _tabBar()
    ];
  }

  Widget _tabBar() {
    return SliverToBoxAdapter(
      child:SizedBox(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              '评论',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(48),
                  fontWeight: FontWeight.w500),
            ),
          ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _userRepository);
  }

  Widget _content() {
    return SliverToBoxAdapter(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(0))),
        elevation: 0,
        margin: EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(42),
              vertical: ScreenUtil().setHeight(15)),
          child: _buildContent(),
        ),
      ),
    );
  }

  _postInfo() {
    return SliverToBoxAdapter(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(0))),
        margin: EdgeInsets.all(0),
        elevation: 0,
        child: const Text("_post Info"),
      ),
    );
  }

  _buildContent() {
    var text = _post.text;
    var index = text.indexOf('//@');
    if (_post.imageUrl != '') {
      switch (index) {
        case -1:
          text = '$text ￥-${_post.imageUrl}-￥';
          break;
        case 0:
          text = ' ￥-${_post.imageUrl}-￥$text';
          break;
        default:
          text = '${text.substring(0, index - 1)} ￥-${_post.imageUrl}-￥${text.substring(index, text.length)}';
      }
    }
    textSend = text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text == '' ? Container() : _postText(text),
        SizedBox(
          height: ScreenUtil().setHeight(10),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setHeight(5)),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(21))),
          child: _buildForward(),
        ),
      ],
    );
  }

  _postText(String text) {
    return ExtendedText(
      text,
      style: TextStyle(fontSize: ScreenUtil().setSp(46)),
    );
  }

  _buildImage() {
    var url;
    url = _post.forwardImageUrl;
    List images = url.split('￥');
    if (images[0] == '') {
      return Container();
    } else if (images.length == 1) {
      return InkWell(
        onTap: () {
          },
        child: Hero(
            tag: '${_post.postId.toString() + images[0]}0',
            child: Container(
              /*constraints: BoxConstraints(maxHeight: ScreenUtil().setHeight(700),
                      maxWidth: ScreenUtil().setWidth(600)),*/
              child: ExtendedImage.network(NetConfig.ip + images[0],
                  cache: true,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.black12, width: 0.5),
                  borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(21))),
            )
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(
            maxHeight: ScreenUtil().setWidth(gridHeight[images.length])),
        child: GridView.count(
          padding: const EdgeInsets.all(0),
          controller: _gridController,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          mainAxisSpacing: ScreenUtil().setWidth(12),
          crossAxisSpacing: ScreenUtil().setWidth(12),
          crossAxisCount: images.length < 3 ? 2 : 3,
          children: List.generate(images.length, (index) {
            return InkWell(
              onTap: () {
              },
              child: Hero(
                tag: _post.postId.toString() + images[index] + index.toString(),
                child: ExtendedImage.network(
                  NetConfig.ip + images[index],
                  fit: BoxFit.cover,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(21)),
                  cache: true,
                ),
              ),
            );
          }),
        ),
      );
    }
  }

  _buildForward() {
    if (_post.forwardId != null && _post.forwardName == null) {
      return const SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Icon(Icons.error_outline),
            Text('哦豁，内容已不在了'),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _postText('@${_post.forwardName} ：${_post.forwardText}'),
          _buildImage(),
        ],
      );
    }
  }

  _buildInputBar() {
    return Positioned(
      bottom: 0,
      child: Card(
        margin: const EdgeInsets.all(0),
        elevation: 100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Container(
          height: 120.h,
          width: ScreenUtil().setWidth(1080),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  icon: const Icon(MyIcons.image, color: Colors.grey, size: 15),
                  label: Text(
                    '说点什么吧...                             ',
                    style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                  ),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(160),
                child: TextButton(
                  onPressed: () async {
                    if (_post.isLiked == 0) {
                      var res = await NetRequester.request(
                          Apis.likePost(_post.postId));
                      if (res['code'] == '1') {
                        setState(() {
                          _post.isLiked = 1;
                          _post.likeNum++;
                        });
                      }
                    } else {
                      var res = await NetRequester.request(
                          Apis.cancelLikePost(_post.postId));
                      if (res['code'] == '1') {
                        setState(() {
                          _post.isLiked = 0;
                          _post.likeNum--;
                        });
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    _post.isLiked == 1 ? MyIcons.like_fill : MyIcons.like,
                    color: _post.isLiked == 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(160),
                child: TextButton(
                  onPressed: () {
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(MyIcons.retweet, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
