import 'package:flutter/material.dart';
import 'dart:async';

class MyErrorWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final int countdownSeconds;
  final VoidCallback onClose;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? iconColor;

  const MyErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.countdownSeconds = 5,
    required this.onClose,
    this.actions,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<MyErrorWidget> createState() => _MyErrorWidgetState();
}

class _MyErrorWidgetState extends State<MyErrorWidget> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ?? (isDark ? Colors.grey[900]! : Colors.white);
    final iconColor = widget.iconColor ?? (isDark ? Colors.red[300]! : Colors.red[700]!);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: bgColor,  // 使用统一的背景色
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: _buildContent(theme, isDark, iconColor, bgColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark, Color iconColor, Color bgColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          widget.icon,
          size: 64,
          color: iconColor,
        ),
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (widget.countdownSeconds > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: '自动关闭 '),
                  TextSpan(
                    text: '$_remainingSeconds',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        const SizedBox(height: 24),
        if (widget.actions != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.actions!
                .map((action) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: action,
            ))
                .toList(),
          )
        else
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconColor,
              foregroundColor: bgColor == Colors.white ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('返回', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
