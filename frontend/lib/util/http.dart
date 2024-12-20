import 'package:http/http.dart' as http;
import 'dart:convert';

class HTTPUtil {
  Future<http.Response> post(String url, Map<String, dynamic>? body, [Map<String, String>? headers]) {
    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        ...?headers,
      },
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> get(String url, [Map<String, String>? headers]) {
    return http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        ...?headers,
      },
    );
  }
}
