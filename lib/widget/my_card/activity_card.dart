import 'package:flutter/material.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({super.key});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/back.jpg',
                  width: 160,
                  height: 140,
                  fit: BoxFit.cover,
                ),
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
                      // 标题区域
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 48),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '周末户外徒步探险之旅周末之旅',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,  // 调整为半粗体
                              color: Colors.blue[800],
                              height: 1.2,  // 增加行高
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.calendar_today, '2023-08-26 09:00'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on, '西湖风景区灵隐步道西湖风景区灵隐步道'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.people, '已报名：2/5人'),
                    ]
                  )
                )
            ),
          ]
        ),
      )
    );
  }

  // 优化信息行间距
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,  // 改为居中对齐
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),  // 增大图标尺寸
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