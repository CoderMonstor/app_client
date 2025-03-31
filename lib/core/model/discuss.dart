class Discuss{
  int? discussId;
  int? userId;
  int? activityId;
  int? replyId;
  int? parentId;
  String? content;
  String? createTime;
  String? updateTime;
  String? nickname;
  String? avatarUrl;

  Discuss({
    this.discussId,
    this.userId,
    this.activityId,
    this.replyId,
    this.parentId,
    this.content,
    this.createTime,
    this.updateTime,
    this.nickname,
    this.avatarUrl,
  });
  factory Discuss.fromJson(Map<String, dynamic> json) {
    return Discuss(
      discussId: json['discussId'],
      userId: json['userId'],
      activityId: json['activityId'],
      replyId: json['replyId'],
      parentId: json['parentId'],
      content: json['content'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      nickname: json['nickname'],
     avatarUrl: json['avatarUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'discussId': discussId,
      'userId': userId,
      'activityId': activityId,
      'replyId': replyId,
      'parentId': parentId,
      'content': content,
      'createTime': createTime,
      'updateTime': updateTime,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }
}