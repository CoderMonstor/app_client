class GoodsReply {
  int? replyId;
  int? goodsCommentId;
  int? userId;
  String? avatarUrl;
  String? username;
  String? beReplyName;
  String? date;
  String? text;
  String? imageUrl;

  GoodsReply({
    this.replyId,
    this.goodsCommentId,
    this.userId,
    this.avatarUrl,
    this.username,
    this.beReplyName,
    this.date,
    this.text,
    this.imageUrl,
  });
  GoodsReply.fromJson(Map<String, dynamic> json) {
    replyId = json['replyId'];
    goodsCommentId = json['goodsCommentId'];
    userId = json['userId'];
    avatarUrl = json['avatarUrl'];
    username = json['username'];
    beReplyName = json['beReplyName'];
    date = json['date'];
    text = json['text'];
    imageUrl = json['imageUrl'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['replyId'] = replyId;
    data['goodsCommentId'] = goodsCommentId;
    data['userId'] = userId;
    data['avatarUrl'] = avatarUrl;
    data['username'] = username;
    data['beReplyName'] = beReplyName;
    data['date'] = date;
    data['text'] = text;
    data['imageUrl'] = imageUrl;
    return data;
  }
}