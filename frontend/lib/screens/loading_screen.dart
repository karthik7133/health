import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';

/// Full-screen loading page shown during ingredient scanning & analysis
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _progressController;

  final List<_StageInfo> _stages = [
    _StageInfo('📸', 'Capturing image...', Color(0xFF2979FF)),
    _StageInfo('🔍', 'Extracting text...', Color(0xFF7C4DFF)),
    _StageInfo('🧠', 'AI is analyzing...', Color(0xFFFF9800)),
    _StageInfo('✨', 'Preparing results...', Color(0xFF00E676)),
  ];

  int _currentStage = 0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..addListener(() {
        final newStage = (_progressController.value * 4).floor().clamp(0, 3);
        if (newStage != _currentStage) {
          setState(() => _currentStage = newStage);
          HapticFeedback.lightImpact();
        }
      });

    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A2E),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Spacer(flex: 2),

              // Animated DNA/Molecule Visualization
              _buildCenterAnimation(),

              SizedBox(height: 48),

              // Stage Indicator
              _buildStageIndicator(),

              SizedBox(height: 32),

              // Progress Bar
              _buildProgressBar(),

              Spacer(flex: 2),

              // Fun Fact at Bottom
              _buildFunFact(),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAnimation() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(200, 200),
                  painter: _OrbitPainter(
                    progress: _rotateController.value,
                    color: _stages[_currentStage].color,
                  ),
                ),
              ),

              // Pulsing center glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 100 + (_pulseController.value * 20),
                    height: 100 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _stages[_currentStage].color.withOpacity(0.3),
                          _stages[_currentStage].color.withOpacity(0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Glassy center circle
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: _stages[_currentStage].color.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _stages[_currentStage].emoji,
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStageIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: Text(
              _stages[_currentStage].label,
              key: ValueKey(_currentStage),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24),
          // Stage dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final isActive = i <= _currentStage;
              final isCurrent = i == _currentStage;
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 6),
                width: isCurrent ? 32 : 12,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: isActive
                      ? _stages[_currentStage].color
                      : Colors.white.withOpacity(0.15),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: _stages[_currentStage].color.withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation(
                      _stages[_currentStage].color,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${(_progressController.value * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFunFact() {
    final facts = [
      '💡 The average person eats 2kg of food additives per year',
      '🧪 There are over 3,000 food additives approved by the FDA',
      '🍎 Organic foods can still contain natural pesticides',
      '🔬 E-numbers are standardized codes for food additives in the EU',
    ];
    final fact = facts[DateTime.now().second % facts.length];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.white.withOpacity(0.4), size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fact,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

class _StageInfo {
  final String emoji;
  final String label;
  final Color color;
  _StageInfo(this.emoji, this.label, this.color);
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OrbitPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Dotted orbit ring
    final dotPaint = Paint()..color = color.withOpacity(0.15);
    for (int i = 0; i < 36; i++) {
      final angle = (i / 36) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
    }

    // Orbiting particles
    for (int i = 0; i < 3; i++) {
      final angle = progress * 2 * math.pi + (i * 2 * math.pi / 3);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Glow
      canvas.drawCircle(
        Offset(x, y),
        8,
        Paint()..color = color.withOpacity(0.2),
      );
      // Particle
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
