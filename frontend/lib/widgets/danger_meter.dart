import 'package:flutter/material.dart';
import 'dart:math' as math;

class DangerMeter extends StatefulWidget {
  final double healthScore; // 1-10
  final double size;

  const DangerMeter({
    super.key,
    required this.healthScore,
    this.size = 200,
  });

  @override
  State<DangerMeter> createState() => _DangerMeterState();
}

class _DangerMeterState extends State<DangerMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.healthScore / 10)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  Color _getColor(double score) {
    if (score < 0.4) return Color(0xFFFF1744); // Red
    if (score < 0.7) return Color(0xFFFF9800); // Orange/Yellow
    return Color(0xFF00E676); // Green
  }

  String _getLabel(double score) {
    if (score < 0.4) return 'High Risk';
    if (score < 0.7) return 'Moderate';
    return 'Safe';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final color = _getColor(value);
        final label = _getLabel(value);

        return Column(
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _MeterPainter(
                value: value,
                color: color,
              ),
            ),
            SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MeterPainter extends CustomPainter {
  final double value; // 0-1
  final Color color;

  _MeterPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Foreground arc (progress)
    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFFF1744),
          Color(0xFFFF9800),
          Color(0xFF00E676),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      math.pi * 0.75,
      math.pi * 1.5 * value,
      false,
      fgPaint,
    );

    // Needle
    final needleAngle = math.pi * 0.75 + (math.pi * 1.5 * value);
    final needleLength = radius - 30;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(
      center,
      8,
      Paint()..color = color,
    );

    // Score text
    final textPainter = TextPainter(
      text: TextSpan(
        text: (value * 10).toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + 40,
      ),
    );
  }

  @override
  bool shouldRepaint(_MeterPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
