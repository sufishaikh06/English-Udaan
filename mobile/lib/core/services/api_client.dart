import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    String? baseUrl,
    required Future<String?> Function() tokenProvider,
    http.Client? httpClient,
  })  : _baseUrl = (baseUrl ?? const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://10.0.2.2:3000',
        )).replaceFirst(RegExp(r'/+$'), ''),
        _tokenProvider = tokenProvider,
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final Future<String?> Function() _tokenProvider;
  final http.Client _httpClient;

  String get baseUrl => _baseUrl;

  Future<Map<String, String>> _headers([String? requestId]) async {
    final token = await _tokenProvider();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (requestId != null) headers['X-Progress-Request-Id'] = requestId;
    debugPrint('[api] auth_header=${token != null && token.isNotEmpty ? 'present' : 'missing'}');
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {String? requestId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    return _request('GET', uri, () async {
      return _httpClient.get(uri, headers: await _headers(requestId));
    });
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {String? requestId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    return _request('PUT', uri, () async {
      return _httpClient.put(
        uri,
        headers: await _headers(requestId),
        body: jsonEncode(body),
      );
    });
  }

  Future<Map<String, dynamic>> _request(
    String method,
    Uri uri,
    Future<http.Response> Function() send,
  ) async {
    debugPrint('[api] $method ${uri.scheme}://${uri.host}:${uri.port}${uri.path}');
    try {
      final response = await send();
      debugPrint('[api] $method ${uri.path} -> ${response.statusCode}');
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on Object catch (error) {
      debugPrint('[api] $method ${uri.path} -> network_error:${error.runtimeType}');
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    String message = 'HTTP error ${response.statusCode}';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        message = decoded['error']['message'] ?? message;
      } else if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'];
      }
    } catch (_) {}
    throw ApiException(statusCode: response.statusCode, message: message);
  }
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
