import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> secureHttpPost(
    Uri url, Map<String, String> headers, String body) async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true; // For testing only
  final request = await client.postUrl(url);
  headers.forEach(request.headers.add);
  request.write(body);
  final response = await request.close();
  return http.Response(await response.transform(utf8.decoder).join(), response.statusCode);
}
