import 'package:flutter/material.dart';
import 'analyzing_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String? _selectedFileName;

Future<void> _pickFile() async {
  setState(() {
    _selectedFileName = 'document.pdf'; // mock for now
  });
}

  void _analyze() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyzingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF52B788);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, color: accentColor),
              const SizedBox(width: 8),
              const Text('Aitbaar AI'),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Message', icon: Icon(Icons.message)),
              Tab(text: 'URL', icon: Icon(Icons.link)),
              Tab(text: 'File Upload', icon: Icon(Icons.upload_file)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Message Tab
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Suspicious message paste karein...',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // URL Tab
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Suspicious link paste karein...',
                            prefixIcon: const Icon(Icons.link, color: accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // File Tab
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 80, color: accentColor.withOpacity(0.5)),
                        const SizedBox(height: 24),
                        const Text(
                          'Upload Document or Image',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Select File'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_selectedFileName != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentColor.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.insert_drive_file, color: accentColor),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _selectedFileName!,
                                    style: const TextStyle(color: accentColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Analyze Button (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Analyze Karo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
