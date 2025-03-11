/*
动态详情页面
 */

import 'package:client/widget/dialog_build.dart';
import 'package:client/widget/image_build.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../core/list_repository/comment_repo.dart';
import '../../core/list_repository/post_repo.dart';
import '../../core/list_repository/user_repo.dart';
import '../../core/model/comment.dart';
import '../../core/model/post.dart';
import '../../core/model/theme_model.dart';
import '../../core/model/user.dart';
import '../../core/net/my_api.dart';
import '../../core/net/net.dart';
import '../../core/net/net_request.dart';
import '../../util/build_date.dart';
import '../../util/my_icon/my_icon.dart';
import '../../util/text_util/special_text_span.dart';
import '../../util/toast.dart';
import '../../widget/build_indicator.dart';
import '../../widget/item_builder.dart';
import '../../widget/my_list_tile.dart';
import '../user/profile_page.dart';
import '../view_images.dart';
import 'common_dialog.dart';


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
      // 确保 likeNum 有默认值
      // print(_post);
      _post.likeNum ??= 0;
      _userRepository = UserRepository(_post.postId, 3);
      _postRepository = PostRepository(_post.postId!, 4);
      _commentRepository = CommentRepository(_post.postId!);
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
                    // return UserCard(user:  user, list: _userRepository,index: index,);
                    return ItemBuilder.buildUserRow(context, user, 3);
                  },
                  sourceList: _userRepository,
                  indicatorBuilder: _buildIndicator,
                  lastChildLayoutType: LastChildLayoutType.none,
                  // padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90)),
              ),
            ),
            LoadingMoreList(
              ListConfig<Comment>(
                  itemBuilder: (BuildContext context, Comment comment, int index) {
                    return ItemBuilder.buildComment(context, comment, _commentRepository, index);
                  },
                  sourceList: _commentRepository,
                  indicatorBuilder: _buildIndicator,
                  lastChildLayoutType: LastChildLayoutType.none,
                  // padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(90))
              ),
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
        // elevation: 0,
        title: Text('动态'),
      ),
      _postInfo(),
      _content(),
      _tabBar()
    ];
  }

  Widget _tabBar() {
    return SliverToBoxAdapter(
      child: StickyHeader(
        header: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(0))),
          child: Consumer<ThemeModel>(
              builder: (BuildContext context, themeModel, _) {
                return TabBar(
                  onTap: (index) {
                    _pageController.jumpToPage(index);
                  },
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColorDark,
                  unselectedLabelColor: themeModel.isDark?Colors.white:Colors.grey,
                  tabs: <Widget>[
                    Tab(text:'赞 ${_post.likeNum}'),
                    Tab(text:'评论 ${_post.commentNum}'),
                    Tab(text:'转发 ${_post.forwardNum}')
                  ],
                );
              }
          ),
        ),
        content: const SizedBox(height: 0),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
    return buildIndicator(context, status, _userRepository);
  }

  Widget _content() {
    return SliverToBoxAdapter(
      child: Card(
        elevation: 0,
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
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().setWidth(0))),
        // margin: const EdgeInsets.all(0),
        elevation: 0,
        child: MyListTile(
          top: 20,
          bottom: ScreenUtil().setWidth(20),
          left: 40,
          right: 20,
          // useScreenUtil: false,
          leading: SizedBox(
            width: ScreenUtil().setWidth(60),
            child: InkWell(
              onTap: (){
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => ProfilePage(userId:_post.userId)));
              },
              child: SizedBox(
                height: ScreenUtil().setWidth(60),
                child:  _post.avatarUrl==''|| _post.avatarUrl == null
                    ?Image.asset("images/flutter_logo.png")
                    :ClipOval(
                      child: ExtendedImage.network('${NetConfig.ip}/images/${_post.avatarUrl!}',cache: true),
                ),
              ),
            ),
          ),
          center: Row(
            children: [
              SizedBox(width: ScreenUtil().setWidth(30)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_post.username!,style: TextStyle(fontSize: ScreenUtil().setSp(25))),
                  Text(buildDate(_post.date!),style: TextStyle(
                      fontSize: ScreenUtil().setSp(14),color: Colors.grey)),
                ],
              ),
            ],
          ),
          trailing: SizedBox(
            width: ScreenUtil().setWidth(40),
            child: TextButton(
              style: TextButton.styleFrom(
                // padding: const EdgeInsets.all(0),
              ),
              onPressed: () {
                DialogBuild.showPostDialog(context, widget.postId);
              },
              child: const Icon(MyIcons.and_more, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  _buildContent() {
    if(_post.forwardId == null){
      var text =_post.text;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text ==''? Container(): _postText(text!),
          SizedBox(height: ScreenUtil().setHeight(10)),
          _buildImage(),
        ],
      );
    }
    var text = _post.text;
    var index = text?.indexOf('//@');
    if(_post.imageUrl!=''){
      switch(index){
        case -1:
          text ='$text ￥-${_post.imageUrl}-￥';
          break;
        case 0:
          text =' ￥-${_post.imageUrl}-￥$text';
          break;
        default:
          text='${text?.substring(0,index!-1)} ￥-${_post.imageUrl}-￥${text?.substring(index!,text.length)}';
      }
    }
    textSend = text!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text==''? Container(): _postText(text),
        SizedBox(height: ScreenUtil().setHeight(10),),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal:ScreenUtil().setWidth(20),
              vertical: ScreenUtil().setHeight(5)),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(21))
          ),
          child: _buildForward(),
        ),
      ],
    );
  }


  _postText(String text) {
    return ExtendedText(text,
      style: TextStyle(fontSize: ScreenUtil().setSp(22)),
      specialTextSpanBuilder: MySpecialTextSpanBuilder(context: context),
      onSpecialTextTap: (dynamic parameter) {
        String str =parameter.toString();
        if (parameter.startsWith("@")) {
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) =>
                  ProfilePage(username: str.substring(1,str.length),)));
        }else if(parameter.startsWith("￥-")){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>
                  ViewImgPage(images: [str.substring(2,str.length-3)],
                    index: 0,postId: _post.postId.toString(),)));
        }
      },
    );
  }

  _buildImage() {
    String url;
    if(_post.forwardId != null){
      url = _post.forwardImageUrl ?? "";
    }else{
      url = _post.imageUrl ?? "";
    }
    List images = url.split('￥');
    if (images[0] == '') {
      return Container();
    } else if (images.length == 1) {
      return ImageBuild.singlePostImage(context,widget.postId!,images);
    } else {
      return ImageBuild.multiPostImage(context, widget.postId!,images);
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
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        // width: double.infinity,
        width: ScreenUtil().setWidth(700),
        child: TextButton(onPressed: (){
          showDialog(context: context,
              builder: (context){
                return CommentDialog(postId: _post.postId,list: _commentRepository);
              }
          );
        },
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              color: Colors.grey,
            ),
          ),
            child: const Text(
                "     说点什么吧……"),
        ),
      ),
    );
  }
}
