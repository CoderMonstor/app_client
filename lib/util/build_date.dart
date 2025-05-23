//构建日期
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart'; // 导入 intl 包

String buildDate(String date) {
  var now = DateTime.now();
  var dateTime = DateTime.parse(date);
  var yesterday = DateTime(now.year, now.month, now.day-1, 23, 59, 59);
  var beforeYesterday = DateTime(now.year, now.month, now.day-2, 23, 59, 59);
  var minutes = now.difference(dateTime).inMinutes;
  if(minutes == 0){
    return '刚刚';
  } else if(minutes < 60){
    return '$minutes分钟前';
  }else if(dateTime.isAfter(yesterday)){
    return '今天${date.substring(date.length-9,date.length-3)}';
  }else if(dateTime.isAfter(beforeYesterday)){
    return '昨天${date.substring(date.length-9,date.length-3)}';
  }else if(dateTime.year < now.year){
    return date.substring(0,date.length-3);
  }else{
    return date.substring(5,date.length-3);
  }
}

DateTime? parseDateTime(String? timeString) {
  if (timeString == null || timeString.isEmpty) return null;

  try {
    // 格式1: ISO 8601（带时区）
    if (timeString.contains('T')) {
      return DateTime.parse(timeString).toLocal();
    }

    // 格式2: 自定义格式（"yyyy-MM-dd HH:mm"）
    final format = DateFormat('yyyy-MM-dd HH:mm');
    return format.parse(timeString);
  } catch (e) {
    debugPrint('时间解析失败: $e');
    return null;
  }
}
String formatCommentTime(String timestamp) {
  final date = DateTime.parse(timestamp);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 7) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays}天前';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours}小时前';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}分钟前';
  }
  return '刚刚';
}
String buildActivityTime(String dateTimeStr) {
  DateTime dateTime;
  try {
    dateTime = DateTime.parse(dateTimeStr); // 解析 ISO 8601 格式
  } catch (_) {
    try {
      dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(dateTimeStr); // 解析 "yyyy-MM-dd HH:mm"
    } catch (_) {
      return "Invalid date format";
    }
  }
  return DateFormat("yyyy-MM-dd HH:mm").format(dateTime); // 格式化为 "yyyy-MM-dd HH:mm:ss"
}
String buildFormatTime(DateTime dateTime){
  return DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
}