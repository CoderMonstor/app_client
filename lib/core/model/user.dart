class User {
  int? userId;
  String? email;
  String? username;
  String? avatarUrl;
  String? bio;
  String? birthDay;
  int? gender;
  String? city;
  String? backImgUrl;
  int? postNum;
  int? fanNum;
  int? followNum;
  int? isFollow;

  // 构造函数，用于创建一个空的 User 对象
  User({
    this.userId,
    this.email,
    this.username,
    this.avatarUrl,
    this.bio,
    this.birthDay,
    this.gender,
    this.city,
    this.backImgUrl,
    this.postNum,
    this.fanNum,
    this.followNum,
    this.isFollow,
  });

  User.none()
      : userId = 0,
        email = '1508537662@qq.com',
        username = 'lisa',
        avatarUrl = '',
        bio = '1508537662',
        birthDay = '2000-01-01',
        gender = 1,
        city = '宁夏-银川',
        backImgUrl = '',
        postNum = 0,
        fanNum = 0,
        followNum = 0,
        isFollow = 0;

  User.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] ?? 0,
        email = json['email'] ?? '',
        username = json['username'] ?? '',
        avatarUrl = json['avatarUrl'] ?? '',
        bio = json['bio'] ?? '',
        birthDay = json['birthDay'] ?? '',
        gender = json['gender'] ?? 0,
        city = json['city'] ?? '',
        backImgUrl = json['backImgUrl'] ?? '',
        postNum = json['postNum'] ?? 0,
        fanNum = json['fanNum'] ?? 0,
        followNum = json['followNum'] ?? 0,
        isFollow = json['isFollow'] ?? 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['userId'] = userId;
    data['email'] = email;
    data['username'] = username;
    data['avatarUrl'] = avatarUrl;
    data['bio'] = bio;
    data['birthDay'] = birthDay;
    data['gender'] = gender;
    data['city'] = city;
    data['backImgUrl'] = backImgUrl;
    data['postNum'] = postNum;
    data['fanNum'] = fanNum;
    data['followNum'] = followNum;
    data['isFollow'] = isFollow;
    return data;
  }

  @override
  String toString() {
    return 'User{userId: $userId, email: $email, username: $username, avatarUrl: $avatarUrl, bio: $bio, birthDay: $birthDay, gender: $gender, city: $city, backImgUrl: $backImgUrl, postNum: $postNum, fanNum: $fanNum, followNum: $followNum, isFollow: $isFollow}';
  }
}
