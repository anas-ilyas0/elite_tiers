import 'dart:convert';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendForgetPasswordRequest(String email) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${baseUrl}forget-password'),
    );

    request.fields.addAll({
      'email': email,
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      return {
        'status': 'error',
        'message': 'Error: ${response.statusCode} - ${response.reasonPhrase}',
      };
    }
  } catch (e) {
    return {
      'status': 'error',
      'message': 'Exception: $e',
    };
  }
}
