import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'results_screen.dart';
import 'history_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _logoPulseController;
  late Animation<double> _logoPulseAnimation;
  final TextEditingController _msgController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isLoading = false;
  Map<String, dynamic> analysisResult = {};
  
  // Rotating Tips
  final List<String> _safetyTips = [
    "Jazz never asks for your OTP - never trust such SMS",
    "HBL has no official Gmail account - its always a scam",
    "Asked for registration fee? 100% Scam",
    "Won a lucky draw? Verify with Aitbaar AI first",
    "Bank employees never ask for your password",
  ];
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  // Colors
  final Color _bgColor = const Color(0xFF235347);
  final Color _cardBg = const Color(0xFF1A3F35);
  final Color _primaryGreen = const Color(0xFF8EB69B);
  final Color _warningYellow = const Color(0xFFD97706);
  final Color _dangerRed = const Color(0xFFEF4444);
  final Color _bodyText = const Color(0xFFFFFFFF);
  final Color _headingText = const Color(0xFFFFFFFF);
  final Color _greyText = const Color(0xFFA8D5B5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _logoPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _logoPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _logoPulseController, curve: Curves.easeInOut),
    );
    
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _safetyTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _logoPulseController.dispose();
    _tabController.dispose();
    _msgController.dispose();
    _urlController.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  Future<void> _analyzeNow() async {
    if (_isLoading) return;

    final tabIndex = _tabController.index;
    
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> analysisResult;
      
      if (tabIndex == 0) {
        final input = _msgController.text;
        if (input.trim().isEmpty) throw "Please enter a message";
        analysisResult = await ApiService.analyzeText(messageText: input);
      } else if (tabIndex == 1) {
        final input = _urlController.text;
        if (input.trim().isEmpty) throw "Please enter a URL";
        // Passing the URL to the 'url' parameter as expected by typical APIs, 
        // while also ensuring messageText is provided if required
        analysisResult = await ApiService.analyzeText(messageText: "", url: input);
      } else {
        if (_selectedFilePath == null) throw "Please select a file first";
        analysisResult = await ApiService.analyzeFile(File(_selectedFilePath!));
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(result: analysisResult),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: _dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          "Reporting...",
          style: GoogleFonts.poppins(color: _headingText, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Reporting to FIA Cybercrime Unit...",
          style: GoogleFonts.poppins(color: _bodyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: GoogleFonts.poppins(color: _primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 32),
              _buildInputSection(),
              const SizedBox(height: 32),
              _buildQuickStats(),
              const SizedBox(height: 32),
              _buildRecentAlerts(),
              const SizedBox(height: 32),
              _buildSafetyTips(),
              const SizedBox(height: 32),
              _buildEmergencyButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. APP BAR
  Widget _buildAppBar() {
    return Row(
      children: [
        ScaleTransition(
          scale: _logoPulseAnimation,
          child: Image.asset(
            'assets/images/logo.png',
            width: 35,
            height: 35,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Aitbaar AI",
              style: GoogleFonts.poppins(
                color: _headingText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Detect Scams. Stay Safe.",
              style: GoogleFonts.poppins(
                color: _greyText,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.history, color: _headingText, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  // 2. INPUT SECTION
  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What do you want to check?",
          style: GoogleFonts.poppins(
            color: _headingText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: _primaryGreen,
                labelColor: _primaryGreen,
                unselectedLabelColor: _greyText,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.message), text: "Message"),
                  Tab(icon: Icon(Icons.link), text: "URL Scan"),
                  Tab(icon: Icon(Icons.upload_file), text: "File Upload"),
                ],
              ),
              SizedBox(
                height: 180,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Text Input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _msgController,
                        maxLines: null,
                        expands: true,
                        style: GoogleFonts.poppins(color: _bodyText),
                        decoration: InputDecoration(
                          hintText: "Paste suspicious message here...",
                          hintStyle: GoogleFonts.poppins(color: _greyText),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // URL Input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: TextField(
                          controller: _urlController,
                          style: GoogleFonts.poppins(color: _bodyText),
                          decoration: InputDecoration(
                            hintText: "Paste suspicious link here...",
                            hintStyle: GoogleFonts.poppins(color: _greyText),
                            filled: true,
                            fillColor: _bgColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.content_paste, color: _primaryGreen),
                              onPressed: () {
                                // Paste action placeholder
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // File Upload
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () async {
                 FilePickerResult? result = await FilePicker.platform.pickFiles(
                  withData: true,
);
                          if (result != null) {
                            setState(() {
                              _selectedFileName = result.files.single.name;
                              _selectedFilePath = result.files.single.path;
                            });
                          }
                        },
                        child: CustomPaint(
                          painter: DashedBorderPainter(color: _greyText),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, color: _greyText, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedFileName ?? "Tap to browse files",
                                  style: GoogleFonts.poppins(color: _bodyText),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _analyzeNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _primaryGreen.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading 
                ? const SizedBox(
                    width: 24, 
                    height: 24, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : Text(
                    "Analyze Now 🔍",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // 3. QUICK STATS BAR
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.warning_amber_rounded, "24", "Scams\nToday", _dangerRed)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.group, "156", "Community\nReports", _warningYellow)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.verified_user, "89", "Safe\nChecks", const Color(0xFF2E7D32))), // Safe Green
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String number, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            number,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _bodyText,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // 4. RECENT ALERTS SECTION
  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Alerts ⚠️",
          style: GoogleFonts.poppins(
            color: _headingText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildAlertCard("Bank Impersonation", 12, "2 hours ago", _dangerRed),
        const SizedBox(height: 12),
        _buildAlertCard("Lucky Draw Scam", 8, "5 hours ago", _dangerRed),
        const SizedBox(height: 12),
        _buildAlertCard("OTP Fraud", 19, "Yesterday", _warningYellow),
      ],
    );
  }

  Widget _buildAlertCard(String type, int trustScore, String time, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    color: _bodyText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Trust Score: $trustScore",
                        style: GoogleFonts.poppins(
                          color: borderColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        color: _greyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultsScreen(result: analysisResult)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen.withOpacity(0.15),
              foregroundColor: const Color(0xFF2E7D32),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "View Report",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // 5. SAFETY TIPS SECTION
  Widget _buildSafetyTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Safety Tip of the Day 💡",
          style: GoogleFonts.poppins(
            color: _headingText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: _warningYellow, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: _warningYellow, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    _safetyTips[_currentTipIndex],
                    key: ValueKey<int>(_currentTipIndex),
                    style: GoogleFonts.poppins(
                      color: _bodyText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. EMERGENCY BUTTON
  Widget _buildEmergencyButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _dangerRed.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showReportDialog,
              icon: const Icon(Icons.campaign, color: Colors.white, size: 28),
              label: Text(
                "Report Immediately",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Active scam? Alert FIA Cybercrime Unit now",
            style: GoogleFonts.poppins(
              color: _dangerRed,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), 
        const Radius.circular(12)));

    final dashPath = Path();
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measurePath.length) {
        dashPath.addPath(measurePath.extractPath(distance, distance + 6), Offset.zero);
        distance += 12; // 6 drawn, 6 gap
      }
    }
    
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
