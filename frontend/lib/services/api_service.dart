import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://192.168.1.43:8001';
      }
    } catch (e) {
      // Ignored: fallback to localhost for Web/Desktop
    }
    return 'http://192.168.1.43:8001';
  }

  static const Duration _timeoutDuration = Duration(seconds: 300);
  static const String _serverErrorMsg = "Server se connect nahi ho pa raha. Backend chalu karo.";
  static const String _parseErrorMsg = "Response samajh nahi aya";

  /// 1. Analyze Text
  static Future<Map<String, dynamic>> analyzeText({
    required String messageText,
    String url = "",
    String phone = "",
    String senderName = "",
    String email = "",
  }) async {
    final uri = Uri.parse('$baseUrl/analyze/text');
    final body = jsonEncode({
      "message_text": messageText,
      "url": url,
      "phone": phone,
      "sender_name": senderName,
      "email": email,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(_timeoutDuration);

      return _processResponse(response);
    } on TimeoutException {
      throw "Server timeout (60s). Agents bohat slow hain.";
    } on SocketException {
      throw _serverErrorMsg;
    } catch (e) {
      throw _serverErrorMsg;
    }
  }

  /// 2. Analyze File
  static Future<Map<String, dynamic>> analyzeFile(File file) async {
    final uri = Uri.parse('$baseUrl/analyze/file');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } on TimeoutException {
      throw "Server timeout (60s). Agents bohat slow hain.";
    } on SocketException {
      throw _serverErrorMsg;
    } catch (e) {
      throw _serverErrorMsg;
    }
  }

  /// 3. Check Health
  static Future<bool> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw _parseErrorMsg;
      }
    } else {
      throw "Server ne error diya: ${response.statusCode}";
    }
  }
}
