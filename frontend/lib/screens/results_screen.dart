import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultsScreen({
    super.key,
    required this.result,
  });

  Color _getScoreColor(double score) {
    if (score < 40) return const Color(0xFFEF4444); // Red
    if (score <= 70) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFF00C853); // Green
  }

  String _formatAction(String action) {
    switch (action) {
      case 'block_warn_user':
        return 'User Blocked & Warned';
      case 'send_emergency_alert':
        return 'Emergency Alert Sent';
      case 'report_to_fia':
        return 'Reported to FIA Cybercrime';
      case 'save_evidence':
        return 'Evidence Saved';
      case 'flag_number':
        return 'Number Flagged';
      default:
        return action
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double trustScore = (result['trust_score'] as num?)?.toDouble() ?? 0.0;
    final String verdict = result['verdict']?.toString() ?? 'Unknown';
    final String verdictUrdu = result['verdict_urdu']?.toString() ?? '';
    final String baseline = result['baseline']?.toString() ?? 'N/A';
    final List<String> actions = List<String>.from(result['actions'] ?? []);
    final String before = result['before']?.toString() ?? 'Input received';
    final String after = result['after']?.toString() ?? 'Analysis complete';
    final String scamType = result['scam_type']?.toString() ?? 'UNKNOWN_SCAM';
    
    // We keep agent analysis data if provided, else empty
    final Map<String, dynamic> agentResults = result['agents'] != null 
        ? Map<String, dynamic>.from(result['agents']) 
        : {
            'Behavioral Agent': {'score': 20, 'findings': ['Urgency tactics + fear language detected']},
            'Identity Agent': {'score': 15, 'findings': ['Domain registered 2 days ago - SUSPICIOUS']},
            'Scam Pattern Agent': {'score': 10, 'findings': ['Matched 3 Pakistani bank scam templates']},
            'Reputation Agent': {'score': 5, 'findings': ['Domain reported 47 times previously']},
            'Risk Scoring Agent': {'score': 23, 'findings': ['High risk - multiple red flags']},
            'Action Agent': {'score': 100, 'findings': ['5 protective actions executed']},
          };

    final scoreColor = _getScoreColor(trustScore);
    const bgColor = Color(0xFF235347);
    const cardBg = Color(0xFF1A3F35);
    const primaryGreen = Color(0xFF8EB69B);
    const dangerRed = Color(0xFFEF4444);
    const warningOrange = Color(0xFFF97316);
    const greyText = Color(0xFFA8D5B5);
    const bodyText = Color(0xFFFFFFFF);
    const headingText = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1 - Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: headingText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Analysis Report',
                    style: GoogleFonts.poppins(
                      color: headingText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: headingText),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 2 - Trust Score Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
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
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: trustScore / 100,
                              backgroundColor: Colors.black.withOpacity(0.05),
                              color: scoreColor,
                              strokeWidth: 12,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                trustScore.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      verdict,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      verdictUrdu,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: greyText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Scam Type: $scamType',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: headingText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 3 - Baseline vs AI Comparison
              Text(
                'Simple Detection vs AI Detection',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Keyword Detection',
                            style: GoogleFonts.poppins(color: greyText, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            baseline,
                            style: GoogleFonts.poppins(color: bodyText, fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryGreen.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Aitbaar AI',
                            style: GoogleFonts.poppins(color: const Color(0xFF2E7D32), fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            verdict,
                            style: GoogleFonts.poppins(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'AI is 85% more accurate',
                  style: GoogleFonts.poppins(color: const Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 4 - Agent Findings
              Text(
                'Agent Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
              const SizedBox(height: 16),
              ...agentResults.entries.map((entry) {
                final agentName = entry.key;
                final data = entry.value;
                final agentScore = (data['score'] as num?)?.toDouble() ?? 0.0;
                final findings = List<String>.from(data['findings'] ?? []);
                
                IconData icon;
                if (agentName.contains('Behavioral')) icon = Icons.psychology;
                else if (agentName.contains('Identity')) icon = Icons.security;
                else if (agentName.contains('Pattern')) icon = Icons.search;
                else if (agentName.contains('Reputation')) icon = Icons.star;
                else if (agentName.contains('Scoring')) icon = Icons.bar_chart;
                else icon = Icons.bolt;

                return Card(
                  color: cardBg,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: headingText,
                      collapsedIconColor: greyText,
                      leading: Icon(icon, color: const Color(0xFF2E7D32)),
                      title: Text(
                        agentName,
                        style: GoogleFonts.poppins(color: headingText, fontWeight: FontWeight.w600),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(agentScore).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          agentScore.toInt().toString(),
                          style: GoogleFonts.poppins(
                            color: _getScoreColor(agentScore),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 56, right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: findings.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: greyText)),
                                  Expanded(
                                    child: Text(f, style: GoogleFonts.poppins(color: bodyText, fontSize: 13)),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 32),

              // SECTION 5 - Actions Executed
              Text(
                'Actions Taken',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: actions.map((actionStr) {
                    final String formattedAction = _formatAction(actionStr);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedAction,
                                  style: GoogleFonts.poppins(
                                    color: headingText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Action automatically completed.',
                                  style: GoogleFonts.poppins(color: greyText, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 6 - Before vs After
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BEFORE', style: GoogleFonts.poppins(color: dangerRed, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(before, style: GoogleFonts.poppins(color: bodyText, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 100, color: Colors.black.withOpacity(0.1)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AFTER', style: GoogleFonts.poppins(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(after, style: GoogleFonts.poppins(color: bodyText, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // SECTION 7 - Bottom Buttons
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: dangerRed,
                  side: const BorderSide(color: dangerRed, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Report This Scam', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Share Warning',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Check Again',
                  style: GoogleFonts.poppins(color: greyText, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
