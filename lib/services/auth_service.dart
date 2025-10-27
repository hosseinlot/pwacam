import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://authbank.kiax.ir';

  static final http.Client client = http.Client();

  static Future<Map<String, dynamic>> startRegistration(String username, String displayName) async {
    final response = await client.post(Uri.parse('$baseUrl/webauthn/register/start'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'displayName': displayName}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start registration');
    }
  }

  static Future<Map<String, dynamic>> finishRegistration(String username, Map<String, dynamic> credential) async {
    final response = await client.post(Uri.parse('$baseUrl/webauthn/register/finish'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'credential': credential}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finish registration');
    }
  }

  static Future<Map<String, dynamic>> startAuthentication(String username) async {
    final response = await client.post(Uri.parse('$baseUrl/webauthn/authenticate/start'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start authentication');
    }
  }

  static Future<Map<String, dynamic>> finishAuthentication(String username, Map<String, dynamic> credential) async {
    final response = await client.post(Uri.parse('$baseUrl/webauthn/authenticate/finish'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'credential': credential}));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finish authentication');
    }
  }

  static Future<Map<String, dynamic>> register(String mobile, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finish registration');
    }
  }

  static Future<Map<String, dynamic>> login(String mobile, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to finish registration');
    }
  }
}
