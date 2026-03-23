import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScanningAnimation extends StatefulWidget {
  final String stage;
  final double progress; // 0-1

  const ScanningAnimation({
    super.key,
    required this.stage,
    required this.progress,
  });

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  String _getStageMessage() {
    if (widget.progress < 0.3) return "📸 Processing image...";
    if (widget.progress < 0.6) return "🔍 Extracting text...";
    if (widget.progress < 0.9) return "🧠 AI analyzing...";
    return "✨ Preparing results...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // DNA Helix Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(120, 120),
                painter: _DNAHelixPainter(
                  progress: _controller.value,
                  color: Color(0xFF00E676),
                ),
              );
            },
          ),
          SizedBox(height: 32),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(Color(0xFF00E676)),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 16),

          // Stage message
          Text(
            _getStageMessage(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),

          // Percentage
          Text(
            '${(widget.progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00E676),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _DNAHelixPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DNAHelixPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.width / 2;
    final steps = 20;

    for (int i = 0; i < steps; i++) {
      final t = i / steps;
      final y = size.height * t;
      final angle = progress * 2 * math.pi + t * 4 * math.pi;

      // Left strand
      final x1 = center + math.cos(angle) * 30;
      final nextAngle = angle + (4 * math.pi / steps);
      final nextY = y + (size.height / steps);
      final nextX1 = center + math.cos(nextAngle) * 30;

      canvas.drawLine(
        Offset(x1, y),
        Offset(nextX1, nextY),
        paint,
      );

      // Right strand
      final x2 = center - math.cos(angle) * 30;
      final nextX2 = center - math.cos(nextAngle) * 30;

      canvas.drawLine(
        Offset(x2, y),
        Offset(nextX2, nextY),
        paint,
      );

      // Connecting bars
      if (i % 2 == 0) {
        final connectPaint = Paint()
          ..color = color.withOpacity(0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(x1, y),
          Offset(x2, y),
          connectPaint,
        );
      }

      // Dots
      canvas.drawCircle(
        Offset(x1, y),
        4,
        Paint()..color = color,
      );

      canvas.drawCircle(
        Offset(x2, y),
        4,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_DNAHelixPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
