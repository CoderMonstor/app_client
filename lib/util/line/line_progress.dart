import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LineProgress extends StatefulWidget {
  final Color? color;
  final double? progress;
  final double? totalWidth;

  const LineProgress({
    super.key,
    this.color,
    this.progress,
    this.totalWidth,
  });

  @override
  State<StatefulWidget> createState() => _LineProgressState();
}

class _LineProgressState extends State<LineProgress> {
  @override
  Widget build(BuildContext context) {
    // Ensure non-null values for totalWidth and progress
    final double effectiveTotalWidth = widget.totalWidth ?? ScreenUtil().setWidth(300);
    final double effectiveProgress = widget.progress ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 10),
          color: widget.color,
          height: 3.5,
          width: (effectiveTotalWidth - ScreenUtil().setWidth(130)) * effectiveProgress,
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: ScreenUtil().setWidth(7)),
          width: ScreenUtil().setWidth(108),
          child: Text(
            '${(effectiveProgress * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: widget.color),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey.shade300,
            height: 2,
          ),
        ),
      ],
    );
  }
}
