import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/services/firebase_bootstrap.dart';

/// Provider-neutral AI boundary. The UI never receives or stores a Gemini key.
/// In the showcase build it returns null and the deterministic safety-first
/// response in Care Companion is used instead.
class AiGateway {
  const AiGateway();

  Future<String?> reply(String prompt) async {
    if (FirebaseBootstrap.isReady) {
      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable('aiChat')
            .call<Map<String, dynamic>>({'message': prompt});
        final answer = result.data['answer'];
        if (answer is String && answer.trim().isNotEmpty) return answer.trim();
      } catch (_) {
        // Fall through to the configured endpoint or local demo response.
      }
    }

    if (AppConfig.aiEndpoint.isEmpty) return null;
    try {
      final response = await http
          .post(
            Uri.parse(AppConfig.aiEndpoint),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({'message': prompt}),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final payload = jsonDecode(response.body);
      final answer = payload is Map<String, dynamic> ? payload['answer'] : null;
      return answer is String && answer.trim().isNotEmpty ? answer.trim() : null;
    } catch (_) {
      return null;
    }
  }
}
