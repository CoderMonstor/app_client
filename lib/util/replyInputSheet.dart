import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/model/discuss.dart';

class ReplyInputSheet extends StatefulWidget {
  final Discuss parentComment;
  final Function(String) onSend;

  const ReplyInputSheet({super.key,
    required this.parentComment,
    required this.onSend,
  });

  @override
  _ReplyInputSheetState createState() => _ReplyInputSheetState();
}

class _ReplyInputSheetState extends State<ReplyInputSheet> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '回复 ${widget.parentComment.username}',
                  style: TextStyle(fontSize: 18.w, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 20.w),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '请输入回复内容...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.w)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent, size: 28.w),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      widget.onSend(_textController.text);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ]
      ),
    );
  }
}