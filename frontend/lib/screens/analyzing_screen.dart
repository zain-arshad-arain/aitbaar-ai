import 'package:flutter/material.dart';
import 'dart:async';
import 'results_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  final List<Map<String, dynamic>> _agents = [
    {
      'icon': '🕵️',
      'name': 'Identity Agent',
      'desc': 'sender/domain identity check',
      'status': AgentStatus.waiting,
    },
    {
      'icon': '🎣',
      'name': 'Scam Pattern Agent',
      'desc': 'Pakistani scam templates match',
      'status': AgentStatus.waiting,
    },
    {
      'icon': '🧠',
      'name': 'Behavioral Agent',
      'desc': 'manipulation tactics detect',
      'status': AgentStatus.waiting,
    },
    {
      'icon': '⭐',
      'name': 'Reputation Agent',
      'desc': 'previous reports check',
      'status': AgentStatus.waiting,
    },
    {
      'icon': '📊',
      'name': 'Risk Scoring Agent',
      'desc': 'final trust score calculate',
      'status': AgentStatus.waiting,
    },
    {
      'icon': '⚡',
      'name': 'Action Agent',
      'desc': '5 actions decide and execute',
      'status': AgentStatus.waiting,
    },
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() async {
    for (int i = 0; i < _agents.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentIndex = i;
        _agents[i]['status'] = AgentStatus.analyzing;
      });
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      setState(() {
        _agents[i]['status'] = AgentStatus.done;
      });
    }

    // Ensure indicator reaches 100%
    if (mounted) {
      setState(() {
        _currentIndex = _agents.length; 
      });
    }

    // Wait 1 extra second before navigating
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF2E7D32); // Safe Green
    const bgColor = Color(0xFF235347);
    const cardBg = Color(0xFF1A3F35);
    const bodyText = Color(0xFFFFFFFF);
    const greyText = Color(0xFFA8D5B5);

    // calculate overall progress
    double progressValue = _agents.isEmpty ? 0 : (_currentIndex / _agents.length);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Analysis in Progress', style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.black.withOpacity(0.05),
                      color: accentColor,
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${(progressValue * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _agents.length,
                itemBuilder: (context, index) {
                  final agent = _agents[index];
                  final status = agent['status'] as AgentStatus;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: status == AgentStatus.analyzing
                            ? accentColor
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    color: status == AgentStatus.done
                        ? accentColor.withOpacity(0.05)
                        : cardBg,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            agent['icon'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agent['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: bodyText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  agent['desc'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildStatusIndicator(status, accentColor, greyText),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(AgentStatus status, Color accentColor, Color greyText) {
    switch (status) {
      case AgentStatus.waiting:
        return Text('Waiting', style: TextStyle(color: greyText.withOpacity(0.5)));
      case AgentStatus.analyzing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Analyzing...', style: TextStyle(color: Color(0xFFD97706))), // Warning yellow
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        );
      case AgentStatus.done:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Done', style: TextStyle(color: accentColor)),
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: accentColor, size: 16),
          ],
        );
    }
  }
}

enum AgentStatus { waiting, analyzing, done }
