import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Email2FAService {
  static String generateCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<void> sendCode({
    required String email,
    required String code,
  }) async {
    const serviceId = 'service_xl50dt7';
    const templateId = 'template_nc77wb6';
    const publicKey = 'F_wS6zf-TbPyZPe5f';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': publicKey,
        'template_params': {
          'to_email': email,
          'code': code,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send verification code.');
    }
  }
}