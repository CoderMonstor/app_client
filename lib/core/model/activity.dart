class Activity {
  int? activityId;
  int? status;
  int? hostUserId;
  String? activityName;
  String? activityImage;
  String? activityTime;
  String? location;
  int? maxParticipants;
  int? currentParticipants;
  String? content;
  String? details;
  String? createTime;
  String? updateTime;
  int? isRegistered;
  int? isPraised;

  Activity({
    this.activityId,
    this.status,
    this.hostUserId,
    this.activityName,
    this.activityImage,
    this.activityTime,
    this.location,
    this.maxParticipants,
    this.currentParticipants,
    this.content,
    this.details,
    this.createTime,
    this.updateTime,
    this.isRegistered,
    this.isPraised,
  });

  // 增强版解析方法
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: _parseInt(json['activityId']),
      status: _parseInt(json['status']),
      hostUserId: _parseInt(json['hostUserId']),
      activityName: json['activityName']?.toString(),
      activityImage: json['activityImage']?.toString(),
      activityTime: json['activityTime']?.toString(),
      location: json['location']?.toString(),
      maxParticipants: _parseInt(json['maxParticipants']),
      currentParticipants: _parseInt(json['currentParticipants']),
      content: json['content']?.toString(),
      details: json['details']?.toString(),
      createTime: json['createTime']?.toString(),
      updateTime: json['updateTime']?.toString(),
      isRegistered: _parseInt(json['isRegistered']),
      isPraised: _parseInt(json['isPraised']),
    );
  }

  // 通用类型转换方法
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'status': status,
      'hostUserId': hostUserId,
      'activityName': activityName,
      'activityImage': activityImage,
      'activityTime': activityTime,
      'location': location,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'content': content,
      'details': details,
      'createTime': createTime,
      'updateTime': updateTime,
      'isRegistered': isRegistered,
      'isPraised': isPraised,
    };
  }
}