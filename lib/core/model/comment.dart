/*
这个类主要用来封装评论的数据，包括评论的id，用户id，用户名，头像，评论内容，评论时间，评论图片，评论点赞数，评论回复数，评论回复列表等。
在fromJson和toJson方法中，分别将json数据转换为Comment对象和Comment对象转换为json数据。
@[param]:
commentId: 评论id
userId: 用户id
avatarUrl: 用户头像
username: 用户名
date: 评论时间
text: 评论内容
imageUrl: 评论图片
isLiked: 评论是否点赞
likeNum: 评论点赞数
replyNum: 评论回复数
replyList: 评论回复列表
 */
import 'package:client/core/model/reply.dart';

class Comment {
  int? commentId;
  int? userId;
  String? avatarUrl;
  String? username;
  String? date;
  String? text;
  String? imageUrl;
  int? isLiked;
  int? likeNum;
  int? replyNum;
  List<Reply>? replyList;


  Comment(
      {this.commentId,
        this.userId,
        this.avatarUrl,
        this.username,
        this.date,
        this.text,
        this.imageUrl,
        this.isLiked,
        this.likeNum,
        this.replyNum,
        this.replyList});

  Comment.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    userId = json['userId'];
    avatarUrl = json['avatarUrl'];
    username = json['username'];
    date = json['date'];
    text = json['text'];
    imageUrl = json['imageUrl'];
    isLiked = json['isLiked'];
    likeNum = json['likeNum'];
    replyNum = json['replyNum'];
    if (json['replyList'] != null) {
      replyList = <Reply>[];
      json['replyList'].forEach((v) {
        replyList?.add(Reply.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commentId'] = commentId;
    data['userId'] = userId;
    data['avatarUrl'] = avatarUrl;
    data['username'] = username;
    data['date'] = date;
    data['text'] = text;
    data['imageUrl'] = imageUrl;
    data['isLiked'] = isLiked;
    data['likeNum'] = likeNum;
    data['replyNum'] = replyNum;
    if (replyList != null) {
      data['replyList'] = replyList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}