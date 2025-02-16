/*
评论回复
@[param]:
replyId:回复id
commentId:评论id
userId:用户id
avatarUrl:头像
username:用户名
date:日期
text:回复内容
imageUrl:图片
isLiked:是否点赞
likeNum:点赞数
 */
class Reply {
  int? replyId;
  int? commentId;
  int? userId;
  String? avatarUrl;
  String? username;
  String? beReplyName;
  String? date;
  String? text;
  String? imageUrl;
  int? isLiked;
  int? likeNum;

  Reply(
      {this.replyId,
        this.commentId,
        this.userId,
        this.avatarUrl,
        this.username,
        this.beReplyName,
        this.date,
        this.text,
        this.imageUrl,
        this.isLiked,
        this.likeNum});

  Reply.fromJson(Map<String, dynamic> json) {
    replyId = json['replyId'];
    commentId = json['commentId'];
    userId = json['userId'];
    avatarUrl = json['avatarUrl'];
    username = json['username'];
    beReplyName = json['beReplyName'];
    date = json['date'];
    text = json['text'];
    imageUrl = json['imageUrl'];
    isLiked = json['isLiked'];
    likeNum = json['likeNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['replyId'] = replyId;
    data['commentId'] = commentId;
    data['userId'] = userId;
    data['avatarUrl'] = avatarUrl;
    data['username'] = username;
    data['beReplyName'] = beReplyName;
    data['date'] = date;
    data['text'] = text;
    data['imageUrl'] = imageUrl;
    data['isLiked'] = isLiked;
    data['likeNum'] = likeNum;
    return data;
  }
}