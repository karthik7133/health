import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../models/analysis_result.dart';
import '../widgets/glass_card.dart';
import '../services/scan_history_service.dart';
import 'chatbot_screen.dart';

class ResultScreen extends StatefulWidget {
  final AnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _meterController;
  late Animation<double> _meterAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Auto-save to scan history
    ScanHistoryService.saveScan(widget.result);

    _meterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    final normalizedScore = widget.result.healthScore.toDouble().clamp(0, 10) / 10.0;
    _meterAnimation = Tween<double>(begin: 0, end: normalizedScore).animate(
      CurvedAnimation(parent: _meterController, curve: Curves.easeOutCubic),
    );
    _meterController.forward();
  }

  int get criticalCount => widget.result.alerts
      .where((a) => a.severity.toLowerCase() == 'high')
      .length;

  int get warningCount => widget.result.alerts
      .where((a) => a.severity.toLowerCase() == 'medium')
      .length;

  int get safeCount => widget.result.alerts
      .where((a) => a.severity.toLowerCase() == 'low')
      .length;

  Color get verdictColor {
    switch (widget.result.verdict.toLowerCase()) {
      case 'safe':
        return Color(0xFF00E676);
      case 'limit':
        return Color(0xFFFF9800);
      default:
        return Color(0xFFFF1744);
    }
  }

  Color _getMeterColor(double score) {
    if (score < 0.4) return Color(0xFFFF1744);
    if (score < 0.7) return Color(0xFFFF9800);
    return Color(0xFF00E676);
  }

  String _getMeterLabel(double score) {
    if (score < 0.4) return 'High Risk';
    if (score < 0.7) return 'Moderate';
    return 'Safe';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.result.productName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              final r = widget.result;
              final alertsList = r.alerts
                  .map((a) => '⚠️ ${a.ingredient} (${a.severity}): ${a.risk}')
                  .join('\n');
              final text = '🔬 Label-Liar AI Analysis\n\n'
                  '📦 Product: ${r.productName}\n'
                  '💯 Health Score: ${r.healthScore}/10\n'
                  '📋 Verdict: ${r.verdict}\n'
                  '⚡ Danger: ${r.dangerLevel}\n\n'
                  '${r.summary}\n\n'
                  '${alertsList.isNotEmpty ? "Alerts:\n$alertsList" : "No alerts!"}\n\n'
                  'Analyzed with Label-Liar 2.0 AI';
              SharePlus.instance.share(ShareParams(text: text));
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              verdictColor.withOpacity(0.15),
              Color(0xFF1A1A2E),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      children: [
                        // Danger Meter
                        AnimatedBuilder(
                          animation: _meterAnimation,
                          builder: (context, child) {
                            final val = _meterAnimation.value;
                            final color = _getMeterColor(val);
                            final label = _getMeterLabel(val);
                            return Column(
                              children: [
                                SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: CustomPaint(
                                    painter: _MeterPainter(
                                        value: val, color: color),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 12),

                        // Verdict Badge - Glassy
                        _buildGlassyBadge(),
                        SizedBox(height: 16),

                        // Stats Row - Glassy
                        Row(
                          children: [
                            _buildGlassyStat(
                                Icons.error, criticalCount, 'Critical',
                                Color(0xFFFF1744)),
                            SizedBox(width: 10),
                            _buildGlassyStat(
                                Icons.warning_amber, warningCount, 'Warnings',
                                Color(0xFFFF9800)),
                            SizedBox(width: 10),
                            _buildGlassyStat(
                                Icons.check_circle, safeCount, 'Safe',
                                Color(0xFF00E676)),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Color(0xFF00E676),
                      indicatorWeight: 3,
                      labelColor: Color(0xFF00E676),
                      unselectedLabelColor: Colors.white.withOpacity(0.5),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(text: 'Alerts'),
                        Tab(text: 'Analysis'),
                        Tab(text: 'Alternatives'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsTab(),
                _buildAnalysisTab(),
                _buildAlternativesTab(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Pass product context to chatbot
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatbotScreen(
                productContext: widget.result.toChatContext(),
              ),
            ),
          );
        },
        backgroundColor: Color(0xFF2979FF),
        icon: Icon(Icons.chat_bubble),
        label: Text('Ask AI'),
      ),
    );
  }

  Widget _buildGlassyBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: verdictColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: verdictColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.result.verdict.toLowerCase() == 'safe'
                    ? Icons.check_circle
                    : widget.result.verdict.toLowerCase() == 'limit'
                        ? Icons.warning
                        : Icons.dangerous,
                color: verdictColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                widget.result.verdict.toUpperCase(),
                style: TextStyle(
                  color: verdictColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassyStat(IconData icon, int count, String label, Color color) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: color),
                SizedBox(height: 6),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: count),
                  duration: Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    );
                  },
                ),
                SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsTab() {
    if (widget.result.alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Color(0xFF00E676).withOpacity(0.4)),
            SizedBox(height: 16),
            Text(
              'No alerts detected!',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.result.alerts.length,
      itemBuilder: (context, index) {
        final alert = widget.result.alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(IngredientAlert alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert.severity.toLowerCase()) {
      case 'high':
        severityColor = Color(0xFFFF1744);
        severityIcon = Icons.error;
        break;
      case 'medium':
        severityColor = Color(0xFFFF9800);
        severityIcon = Icons.warning_amber;
        break;
      default:
        severityColor = Color(0xFF00E676);
        severityIcon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: severityColor.withOpacity(0.2)),
            ),
            child: Theme(
              data: ThemeData(
                dividerColor: Colors.transparent,
                colorScheme: ColorScheme.dark(),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(severityIcon, color: severityColor, size: 22),
                ),
                title: Text(
                  alert.ingredient,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alert.severity,
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.risk,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: severityColor.withOpacity(0.1)),
                        SizedBox(height: 8),
                        Text(
                          'Why it matters:',
                          style: TextStyle(
                            color: severityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          alert.reason,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                        if (alert.sideEffects.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text(
                            'Side Effects:',
                            style: TextStyle(
                              color: severityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 6),
                          ...alert.sideEffects.map((effect) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ',
                                        style: TextStyle(
                                            color: severityColor, fontSize: 13)),
                                    Expanded(
                                      child: Text(
                                        effect,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.psychology, color: Color(0xFF00E676), size: 22),
                ),
                SizedBox(width: 12),
                Text(
                  'AI Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              widget.result.summary,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                height: 1.7,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativesTab() {
    if (widget.result.alternatives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up_outlined,
                size: 64, color: Color(0xFF00E676).withOpacity(0.4)),
            SizedBox(height: 16),
            Text(
              'No alternatives needed!',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.result.alternatives.length,
      itemBuilder: (context, index) {
        final alt = widget.result.alternatives[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF00E676).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF00E676).withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF00E676).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.swap_horiz,
                        color: Color(0xFF00E676),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        alt,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _meterController.dispose();
    super.dispose();
  }
}

// Sticky Tab Bar delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Color(0xFF0D0D0D).withOpacity(0.85),
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

// Meter painter
class _MeterPainter extends CustomPainter {
  final double value;
  final Color color;

  _MeterPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Foreground arc
    if (value > 0) {
      final fgPaint = Paint()
        ..shader = LinearGradient(
          colors: [Color(0xFFFF1744), Color(0xFFFF9800), Color(0xFF00E676)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        math.pi * 0.75,
        math.pi * 1.5 * value,
        false,
        fgPaint,
      );
    }

    // Needle
    final needleAngle = math.pi * 0.75 + (math.pi * 1.5 * value);
    final needleLength = radius - 26;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Center dot
    canvas.drawCircle(center, 5, Paint()..color = color);

    // Score text
    final textPainter = TextPainter(
      text: TextSpan(
        text: (value * 10).toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 24),
    );

    // "/10" label
    final subTextPainter = TextPainter(
      text: TextSpan(
        text: '/10',
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subTextPainter.layout();
    subTextPainter.paint(
      canvas,
      Offset(center.dx - subTextPainter.width / 2, center.dy + 60),
    );
  }

  @override
  bool shouldRepaint(_MeterPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
