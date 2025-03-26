import 'goods_reply.dart';

class GoodsComment {
  int? commentId;
  int? userId;
  int? goodsId;
  String? avatarUrl;
  String? username;
  String? date;
  String? text;
  String? imageUrl;
  int? replyNum;
  List<GoodsReply>? goodsReplyList;

  GoodsComment({
    this.commentId,
    this.userId,
    this.goodsId,
    this.avatarUrl,
    this.username,
    this.date,
    this.text,
    this.imageUrl,
    this.replyNum,
    this.goodsReplyList,
  });

  GoodsComment.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    userId = json['userId'];
    goodsId = json['goodsId'];
    avatarUrl = json['avatarUrl'];
    username = json['username'];
    date = json['date'];
    text = json['text'];
    imageUrl = json['imageUrl'];
    replyNum = json['replyNum'];
    if(json['goodsReplyList'] != null){
      goodsReplyList = <GoodsReply>[];
      json['goodsReplyList'].forEach((v){
        goodsReplyList?.add(GoodsReply.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentId'] = commentId;
    data['userId'] = userId;
    data['goodsId'] = goodsId;
    data['avatarUrl'] = avatarUrl;
    data['username'] = username;
    data['date'] = date;
    data['text'] = text;
    data['imageUrl'] = imageUrl;
    data['replyNum'] = replyNum;
    if(goodsReplyList != null){
      data['goodsReplyList'] = goodsReplyList?.map((v) => v.toJson()).toList();
    }
    return data;
  }

}