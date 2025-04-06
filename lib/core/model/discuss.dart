class Discuss {
  int? discussId;
  int? userId;
  int? activityId;
  int? replyId;
  int? parentId;
  String? content;
  String? createTime;
  String? updateTime;
  String? username;
  String? avatarUrl;
  int? depth;
  String? replyTo;
  List<Discuss>? children;

  Discuss({
    this.discussId,
    this.userId,
    this.activityId,
    this.replyId,
    this.parentId,
    this.content,
    this.createTime,
    this.updateTime,
    this.username,
    this.avatarUrl,
    this.depth,
    this.replyTo,
    this.children,
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
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      depth: json['depth'],
      replyTo: json['replyTo'],
      children: json['children'] != null
          ? (json['children'] as List)
          .map((e) => Discuss.fromJson(e))
          .toList()
          : [],
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
      'username': username,
      'avatarUrl': avatarUrl,
      'depth': depth,
      'replyTo': replyTo,
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }
}
