import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<bool> register(String name, String email, String password) async {
    try {
      Map<String, dynamic> data = {
        "name": name,
        "email": email,
        "password": password,
      };
      final response = await http.post(
        Uri.parse("$_baseUrl/register"),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to register');
      }
    } catch (e) {
      rethrow;
    }
  }
}
