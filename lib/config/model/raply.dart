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
    replyId = json['replyId']??0;
    commentId = json['commentId']??0;
    userId = json['userId']??0;
    avatarUrl = json['avatarUrl']??'';
    username = json['username']??'';
    beReplyName = json['beReplyName']??'';
    date = json['date']??'';
    text = json['text']??'';
    imageUrl = json['imageUrl']??'';
    isLiked = json['isLiked']??0;
    likeNum = json['likeNum']??0;
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