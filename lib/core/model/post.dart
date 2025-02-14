class Post {
  late int postId;
  late int userId;
  late String username;
  late String date;
  late String text;
  late String imageUrl;
  late String avatarUrl;
  late int likeNum;
  late int commentNum;
  late int forwardNum;
  late int isLiked;
  late int isStar;
  late int forwardId;
  late String forwardName;
  late String forwardText;
  late String forwardImageUrl;

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.date,
    required this.text,
    required this.imageUrl,
    required this.avatarUrl,
    required this.likeNum,
    required this.commentNum,
    required this.forwardNum,
    required this.isLiked,
    required this.isStar,
    required this.forwardId,
    required this.forwardName,
    required this.forwardText,
    required this.forwardImageUrl,
  });

  Post.fromJson(Map<String, dynamic> json)
      : postId = json['postId'],
        userId = json['userId'],
        username = json['username'],
        date = json['date'],
        text = json['text'],
        imageUrl = json['imageUrl'],
        avatarUrl = json['avatarUrl'],
        likeNum = json['likeNum'],
        commentNum = json['commentNum'],
        forwardNum = json['forwardNum'],
        isLiked = json['isLiked'],
        isStar = json['isStar'],
        forwardId = json['forwardId'],
        forwardName = json['forwardName'],
        forwardText = json['forwardText'],
        forwardImageUrl = json['forwardImageUrl'];

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'date': date,
      'text': text,
      'imageUrl': imageUrl,
      'avatarUrl': avatarUrl,
      'likeNum': likeNum,
      'commentNum': commentNum,
      'forwardNum': forwardNum,
      'isLiked': isLiked,
      'isStar': isStar,
      'forwardId': forwardId,
      'forwardName': forwardName,
      'forwardText': forwardText,
      'forwardImageUrl': forwardImageUrl,
    };
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.write('Post{');
    buffer.write('postId: $postId, ');
    buffer.write('userId: $userId, ');
    buffer.write('username: $username, ');
    buffer.write('date: $date, ');
    buffer.write('text: $text, ');
    buffer.write('imageUrl: $imageUrl, ');
    buffer.write('avatarUrl: $avatarUrl, ');
    buffer.write('likeNum: $likeNum, ');
    buffer.write('commentNum: $commentNum, ');
    buffer.write('forwardNum: $forwardNum, ');
    buffer.write('isLiked: $isLiked, ');
    buffer.write('isStar: $isStar, ');
    buffer.write('forwardId: $forwardId, ');
    buffer.write('forwardName: $forwardName, ');
    buffer.write('forwardText: $forwardText, ');
    buffer.write('forwardImageUrl: $forwardImageUrl');
    buffer.write('}');
    return buffer.toString();
  }
}
