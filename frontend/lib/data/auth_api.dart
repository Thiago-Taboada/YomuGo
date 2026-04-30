import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';

class AuthApi {
  AuthApi({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  /// POST /auth/register — devuelve cuerpo en bruto para mostrar en el diálogo.
  Future<http.Response> register({
    required String username,
    required String email,
    required String password,
    String? preferredLocale,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    final body = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      if (preferredLocale != null) 'preferredLocale': preferredLocale,
    };
    return _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    );
  }
}
