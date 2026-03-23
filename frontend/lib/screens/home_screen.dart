import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glass_card.dart';
import '../services/scan_history_service.dart';
import '../models/analysis_result.dart';
import 'camera_screen.dart';
import 'chatbot_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _recentScans = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await ScanHistoryService.getHistory();
    if (mounted) {
      setState(() {
        _recentScans = history;
      });
    }
  }

  // Reload history when returning from other screens
  void _navigateAndRefresh(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _loadHistory());
  }

  Color _getVerdictColor(String verdict) {
    switch (verdict.toLowerCase()) {
      case 'safe':
        return Color(0xFF00E676);
      case 'limit':
        return Color(0xFFFF9800);
      default:
        return Color(0xFFFF1744);
    }
  }

  String _timeAgo(String isoTimestamp) {
    final time = DateTime.parse(isoTimestamp);
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
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
              Color(0xFF1A1A2E),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Label-Liar AI',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF00E676).withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF00E676).withOpacity(0.15),
                        child: Icon(Icons.person, color: Color(0xFF00E676), size: 22),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                // Primary CTA - Scan
                GestureDetector(
                  onTap: () => _navigateAndRefresh(CameraScreen()),
                  child: GlassCard(
                    color: Color(0xFF00E676),
                    opacity: 0.12,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF00C853)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan New Product',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Analyze ingredients instantly',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF00E676), size: 18),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // Secondary Actions Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.chat_bubble,
                        title: 'AI Chat',
                        subtitle: 'Ask anything',
                        color: Color(0xFF2979FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatbotScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.delete_sweep,
                        title: 'Clear',
                        subtitle: 'Reset history',
                        color: Color(0xFFFF9800),
                        onTap: () async {
                          await ScanHistoryService.clearHistory();
                          _loadHistory();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('History cleared'),
                                backgroundColor: Color(0xFFFF9800),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Recent Scans
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Scans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_recentScans.isNotEmpty)
                      Text(
                        '${_recentScans.length} scans',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 14),

                if (_recentScans.isEmpty)
                  _buildEmptyHistory()
                else
                  ..._recentScans.take(5).map((scan) => _buildScanCard(scan)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        color: color,
        opacity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return GlassCard(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 12),
            Icon(
              Icons.document_scanner_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.2),
            ),
            SizedBox(height: 14),
            Text(
              'No scans yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap "Scan New Product" to get started',
              style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(Map<String, dynamic> scan) {
    final verdictColor = _getVerdictColor(scan['verdict'] ?? 'Avoid');
    final score = scan['health_score'] ?? 0;
    final alertsCount = scan['alerts_count'] ?? (scan['alerts'] as List?)?.length ?? 0;
    final timestamp = scan['timestamp'] ?? DateTime.now().toIso8601String();

    return GestureDetector(
      onTap: () {
        // Reconstruct and navigate to result screen
        final result = ScanHistoryService.resultFromHistory(scan);
        _navigateAndRefresh(ResultScreen(result: result));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  // Score circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: verdictColor.withOpacity(0.12),
                      border: Border.all(
                        color: verdictColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: verdictColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan['product_name'] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: verdictColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (scan['verdict'] ?? 'Unknown').toString().toUpperCase(),
                                style: TextStyle(
                                  color: verdictColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '$alertsCount alerts',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                              ),
                            ),
                            Spacer(),
                            Text(
                              _timeAgo(timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right,
                      color: Colors.white.withOpacity(0.2), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
