import 'package:client/util/build_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/model/activity.dart';
import '../../core/net/net.dart';
import '../../pages/activity/activity_detail_page.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity; // 添加活动数据对象

  const ActivityCard({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {

  late final int? currentUserId;

  (String text, Color color) get _statusInfo {
    final now = DateTime.now();
    final active = widget.activity;
    // 报名状态判断（需确保活动未取消未结束）
    if (active.isRegistered == 1) return ('已报名', Colors.green);
    // 强制结束或超时结束判断
    final isExpired =parseDateTime(active.activityTime)?.isBefore(now) ?? false;
    if (active.status == 2 || isExpired) return ('已结束', Colors.grey);
    // 时间状态判断
    final isFuture = parseDateTime(active.activityTime)?.isAfter(now) ?? false;
    return isFuture ? ('未开始', Colors.orange) : ('进行中', Colors.blue);
  }

  @override
  Widget build(BuildContext context) {

    final (statusText, statusColor) = _statusInfo;
    final active = widget.activity;
    var images= active.activityImage!.split('￥').first;
    return InkWell(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context)=>ActivityDetailPage(activityId:active.activityId)));
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 140,
            minHeight: 140,
          ),
          child: Row(
            children: [
              // 图片区域优化
              Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: Image.network(
                        '${NetConfig.ip}$images',
                        width: 160,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // const SizedBox(width: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 48),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              active.activityName!,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,  // 调整为半粗体
                                color: Colors.blue[800],
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 11),
                        _buildInfoRow(Icons.calendar_today, buildActivityTime(active.activityTime!)),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.location_on, active.location!),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.people, '已报名：${active.currentParticipants}/${active.maxParticipants}人'),
                      ]
                    )
                  )
              ),
            ]
          ),
        )
      ),
    );
  }

  // 优化信息行间距
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),  // 增加图标与文字间距
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}