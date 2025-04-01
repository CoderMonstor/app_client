
import 'package:client/core/model/goods.dart';

import '../global.dart';

class Apis {
  /*
  * user相关
  * */
  //登录
  static String login(String email, String password) {
    return '/user/logIn?email=$email&password=$password';
  }

  //获取验证码
  static String sendEmail(String email) {
    return '/user/sendEmail?email=$email';
  }

  //注册
  static String addUser(String email, String password, String code) {
    return '/user/addUser?email=$email&password=$password&code=$code';
  }

  //忘记密码
  static String updatePassword(String email, String password, String code) {
    return '/user/updatePwd?email=$email&password=$password&code=$code';
  }

  //根据ID查询用户
  static String findUserById(int userId) {
    int? askId = Global.profile.user?.userId;
    return '/user/findUserById?askId=$askId&userId=$userId';
  }

  static String findUserByName(int askId, String username) {
    return '/user/findUserByName?askId=$askId&username=$username';
  }

  //修改用户信息
  static String updateUserProperty(String property, value) {
    int? userId = Global.profile.user?.userId;
    return '/user/updateUserProperty?userId=$userId&property=$property&value=$value';
  }

  //查找粉丝
  static String findFan(int userId, int page) {
    return '/user/findFan?userId=$userId&page=$page';
  }

  //查找关注的人
  static String findFollow(int userId, int page) {
    return '/user/findFollow?userId=$userId&page=$page';
  }

  //关注一个用户
  static String followAUser(int fanId, int followedId) {
    return '/user/followAUser?fanId=$fanId&followedId=$followedId';
  }

  //关注一个用户
  static String cancelFollowAUser(int fanId, int followedId) {
    return '/user/cancelFollowAUser?fanId=$fanId&followedId=$followedId';
  }

  static String searchUser(int page, String key) {
    int? userId = Global.profile.user!.userId;
    return '/user/searchUser?page=$page&askId=$userId&key=$key';
  }

  /*
  * 动态相关
  * */
  //点赞
  static String likePost(int postId) {
    int? userId = Global.profile.user!.userId;
    return '/post/likePost?userId=$userId&postId=$postId';
  }

  //取消赞
  static String cancelLikePost(int postId) {
    int? userId = Global.profile.user!.userId;
    return '/post/cancelLikePost?userId=$userId&postId=$postId';
  }

  //收藏
  static String starPost(int postId) {
    int? userId = Global.profile.user!.userId;
    return '/post/starPost?userId=$userId&postId=$postId';
  }

  //取消收藏
  static String cancelStarPost(int postId) {
    int? userId = Global.profile.user!.userId;
    return '/post/cancelStarPost?userId=$userId&postId=$postId';
  }

  static String getPostsById(int userId, int page) {
    int? askId = Global.profile.user!.userId;
    return '/post/getPostsById?askId=$askId&userId=$userId&page=$page';
  }

  //关注的动态
  static String getFollowPosts(int userId, int page) {
    return '/post/getFollowPosts?userId=$userId&page=$page';
  }

  //
  static String getStarPosts(int userId, int page) {
    return '/post/getStarPosts?userId=$userId&page=$page';
  }

  //删除post
  static String deletePost(int postId) {
    return '/post/deletePost?postId=$postId';
  }

  //postId查找post
  static String getPostByPostId(int postId) {
    int? userId = Global.profile.user?.userId;
    return '/post/getPostByPostId?postId=$postId&userId=$userId';
  }

  //转发记录
  static String getForwardPost(int postId, int page) {
    return '/post/getForwardPost?postId=$postId&page=$page';
  }

  static String getAllPostsByDate(int userId, int page) {
    return '/post/getAllPostsByDate?userId=$userId&page=$page';
  }

  static String getHotPost(int page) {
    int? askId = Global.profile.user?.userId;
    return '/post/getHotPost?askId=$askId&page=$page';
  }

  static String searchPost(String key, String orderBy, int page) {
    int? askId = Global.profile.user?.userId;
    return '/post/searchPost?askId=$askId&page=$page&key=$key&orderBy=$orderBy';
  }
  //根据关注人搜索
  static String searchFollowPost(String key, int page) {
    int? askId = Global.profile.user?.userId;
    return '/post/searchFollowPost?askId=$askId&page=$page&key=$key';
  }

  static String getLikedUser(int postId, int page) {
    int? userId = Global.profile.user?.userId;
    return '/user/getLikedUser?userId=$userId&postId=$postId&page=$page';
  }

  /*
  * 评论
  * */
  static String getCommentByPostId(int postId, int page) {
    int? userId = Global.profile.user?.userId;
    return '/comment/getCommentByPostId?askId=$userId&postId=$postId&page=$page';
  }

  //点赞评论
  static String likeComment(int commentId) {
    int? userId = Global.profile.user?.userId;
    return '/comment/likeComment?userId=$userId&commentId=$commentId';
  }

  //取消赞评论
  static String cancelLikeComment(int commentId) {
    int? userId = Global.profile.user?.userId;
    return '/comment/cancelLikeComment?userId=$userId&commentId=$commentId';
  }

  //删除
  static String deleteComment(int commentId) {
    return '/comment/deleteComment?commentId=$commentId';
  }

  /*
  * 回复
  * */
  static String likeReply(int replyId) {
    int? userId = Global.profile.user?.userId;
    return '/reply/likeReply?userId=$userId&replyId=$replyId';
  }

  //取消赞
  static String cancelLikeReply(int replyId) {
    int? userId = Global.profile.user?.userId;
    return '/reply/cancelLikeReply?userId=$userId&replyId=$replyId';
  }

  static String getReplyByCommentId(int commentId, int page) {
    int? userId = Global.profile.user?.userId;
    return '/reply/getReplyByCommentId?askId=$userId&commentId=$commentId&page=$page';
  }

  static String deleteReply(int replyId) {
    return '/reply/deleteReply?replyId=$replyId';
  }

  //检查更新
  static String checkUpdate() {
    return '/user/checkUpdate';
  }
  //查询消息列表
  static String getMsgUserList(int page) {
    int? userId = Global.profile.user?.userId;
    return '/msg/getUserMsgList?userId=$userId&page=$page';
  }

  //根据用户查询消息
  static String getMsg(int sender,int receiver) {
    int? sender = Global.profile.user?.userId;
    return '/msg/getMsg?sender=$sender&receiver=$receiver';
  }

  static String getAllProduct(int page){
    int? userId = Global.profile.user?.userId;
    return '/product/getAllProduct?userId=$userId&page=$page';
  }

  static String getProductByProductId(int productId) {
    return '/product/getProductByProductId?productId=$productId';
  }

  static String getProductByCategory(int category, int pageIndex) {
    return '/product/getProductByCategory?productId=$category&pageIndex=$pageIndex';
  }

  /*
    @RequestMapping("/addResale")
    @RequestMapping("/upOrDown")
    @RequestMapping("/updateSaleOrNot")
    @RequestMapping("/searchGoods")
    @RequestMapping("/getGoodsByGoodsId")
    @RequestMapping("/deleteGoods")
    @RequestMapping("/getResaleList")
    @RequestMapping("/getBuyList")
    @RequestMapping("/getMyResaleList")
    @RequestMapping("/getMyBuyList")
    @RequestMapping("/edit")
    @RequestMapping("/getCollectedGoodsByUserId")
    @RequestMapping("/collectGoods")
    @RequestMapping("/cancelCollectGoods")
    @RequestMapping("/getMyOrder")
    @RequestMapping("/getSellOrder")
    @RequestMapping("/addOrder")

   */

  static String addResale(Goods goods) {
    return '/goods/addResale?goods=$goods';
  }
  static String upOrDown(int goodsId) {
    return '/goods/upOrDown?goodsId=$goodsId';
  }
  static String updateSaleOrNot(int goodsId) {
    return '/goods/updateSaleOrNot?goodsId=$goodsId';
  }
  static String searchGoods(String key, int page) {
    int? askId = Global.profile.user?.userId;
    return '/goods/searchGoods?askId=$askId&key=$key&page=$page';
  }
  static String getGoodsByGoodsId(int goodsId) {
    int? askId = Global.profile.user?.userId;
    return '/goods/getGoodsByGoodsId?userId=$askId&goodsId=$goodsId';
  }
  static String deleteGoods(int goodsId) {
    return '/goods/deleteGoods?goodsId=$goodsId';
  }
  static String getResaleList(int page) {
    int? userId = Global.profile.user?.userId;
    return '/goods/getResaleList?userId=$userId&page=$page';
  }
  static String getBuyList(int page) {
    int? userId = Global.profile.user?.userId;
    return '/goods/getBuyList?userId=$userId&page=$page';
  }

  static String getMyGoods(int page){
    int? userId = Global.profile.user?.userId;
    return '/goods/getMyGoods?userId=$userId&page=$page';
  }

  static String edit(Goods goods) {
    return '/goods/edit?goods=$goods';
  }
  static String getCollectedGoodsByUserId(int userId, int page) {
    return '/goods/getCollectedGoodsByUserId?userId=$userId&page=$page';
  }
  static String collectGoods(int goodsId) {
    int? userId = Global.profile.user?.userId;
    return '/goods/collectGoods?userId=$userId&goodsId=$goodsId';
  }
  static String cancelCollectGoods(int goodsId) {
    int? userId = Global.profile.user?.userId;
    return '/goods/cancelCollectGoods?userId=$userId&goodsId=$goodsId';
  }
  static String getMyOrder(int page) {
    int? userId = Global.profile.user?.userId;
    return '/order/getMyOrder?userId=$userId&page=$page';
  }

  static String getGoodsCommentByGoodsId(int goodsId, int pageIndex) {
    int? userId = Global.profile.user?.userId;
    return '/goodsComment/getCommentByGoodsId?askId=$userId&goodsId=$goodsId&page=$pageIndex';
  }

  static String deleteGoodsComment(int i) {
    return '/goodsComment/deleteComment?commentId=$i';
  }

  static String getGoodsReplyByCommentId(int commentId, int pageIndex) {
    int? userId = Global.profile.user?.userId;
    return '/goodsReply/getReplyByCommentId?askId=$userId&commentId=$commentId&page=$pageIndex';
  }

  static String deleteGoodsReply(int i) {
    return '/goodsReply/deleteReply?replyId=$i';
  }

  static String getAllActivities(int userId, int pageIndex) {
    return '/activity/getAllActivities?userId=$userId&page=$pageIndex';
  }

  static String getMyActivities(int userId, int pageIndex) {
    return '/activity/getMyActivities?userId=$userId&page=$pageIndex';
  }

  static String getMyStarActivities(int userId, int pageIndex) {
    return '/activity/getMyStarActivities?userId=$userId&page=$pageIndex';
  }

  static String searchActivity(String key, int pageIndex) {
    int? userId = Global.profile.user?.userId;
    return '/activity/searchActivity?userId=$userId&key=$key&page=$pageIndex';
  }

  static String getActivityDetails(int activityId) {
    int? userId = Global.profile.user?.userId;
    return '/activity/getActivityDetail?userId=$userId&activityId=$activityId';
  }

}
