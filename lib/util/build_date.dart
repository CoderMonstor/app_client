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