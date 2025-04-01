class Activity{
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
  });
  Activity.fromJson(Map<String, dynamic> json) {
    activityId = json['activityId'];
    status = json['status'];
    hostUserId = json['hostUserId'];
    activityName = json['activityName'];
    activityImage = json['activityImage'];
    activityTime = json['activityTime'];
    location = json['location'];
    maxParticipants = json['maxParticipants'];
    currentParticipants = json['currentParticipants'];
    content = json['content'];
    details = json['details'];
    createTime = json['createTime'];
    updateTime = json['updateTime'];
    isRegistered = json['isRegistered'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activityId'] = activityId;
    data['status'] = status;
    data['hostUserId'] = hostUserId;
    data['activityName'] = activityName;
    data['activityImage'] = activityImage;
    data['activityTime'] = activityTime;
    data['location'] = location;
    data['maxParticipants'] = maxParticipants;
    data['currentParticipants'] = currentParticipants;
    data['content'] = content;
    data['details'] = details;
    data['createTime'] = createTime;
    data['updateTime'] = updateTime;
    data['isRegistered'] = isRegistered;
    return data;
  }
}