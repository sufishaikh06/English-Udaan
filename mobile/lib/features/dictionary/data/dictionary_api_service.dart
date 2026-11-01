import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/dictionary_models.dart';

/// The base URL is read from the `--dart-define` compile-time constant that
/// the app already uses for the progress API. No API key is exposed here —
/// all AI keys live exclusively on the backend server.
const _kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

/// Contacts the backend `POST /api/dictionary/lookup` endpoint.
///
/// The dictionary endpoint is intentionally **public** (no Bearer token),
/// because learners who are not signed in must also be able to look up words.
/// Rate limiting and abuse protection live entirely on the server.
class DictionaryApiService {
  DictionaryApiService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  static final _baseUrl = _kApiBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  /// Look up [query] in the dictionary.
  ///
  /// [sourceLanguage]: `'ur'` for Urdu→English, `'en'` for English→Urdu.
  /// [targetLanguage]: the opposite of [sourceLanguage].
  ///
  /// Returns a [DictionaryResult] on success.
  ///
  /// Throws:
  /// - [DictionaryNotFoundException] when the word is not found (404).
  /// - [DictionaryAiUnavailableException] when the AI key is absent (503).
  /// - [DictionaryRateLimitException] when the rate limit is exceeded (429).
  /// - [DictionaryOfflineException] on network/timeout failures.
  /// - [DictionaryApiException] for all other server errors.
  Future<DictionaryResult> lookup({
    required String query,
    String sourceLanguage = 'ur',
    String targetLanguage = 'en',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/dictionary/lookup');
    final requestBody = jsonEncode({
      'query': query.trim(),
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
    });
    debugPrint('[dictionary] POST $uri query="${query.trim()}"');

    try {
      final response = await _http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('[dictionary] response ${response.statusCode}');
      return _handleResponse(response, query);
    } on DictionaryApiException {
      rethrow;
    } on DictionaryOfflineException {
      rethrow;
    } on TimeoutException {
      throw const DictionaryOfflineException();
    } on SocketException {
      throw const DictionaryOfflineException();
    } on Object catch (e) {
      debugPrint('[dictionary] unexpected error: $e');
      throw const DictionaryOfflineException();
    }
  }

  DictionaryResult _handleResponse(http.Response response, String query) {
    if (response.statusCode == 404) {
      String msg = 'Word not found.';
      try {
        final decoded = jsonDecode(response.body) as Map?;
        msg = (decoded?['error']?['message'] as String?) ?? msg;
      } catch (_) {}
      throw DictionaryNotFoundException(msg);
    }
    if (response.statusCode == 503) {
      throw const DictionaryAiUnavailableException();
    }
    if (response.statusCode == 429) {
      throw const DictionaryRateLimitException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Server error ${response.statusCode}.';
      try {
        final decoded = jsonDecode(response.body) as Map?;
        msg = (decoded?['error']?['message'] as String?) ?? msg;
      } catch (_) {}
      throw DictionaryApiException(msg);
    }

    // 2xx — parse the result.
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null)
        throw const DictionaryApiException('Empty response data.');
      return DictionaryResult.fromJson(data);
    } catch (e) {
      if (e is DictionaryApiException) rethrow;
      throw DictionaryApiException('Could not parse server response: $e');
    }
  }
}

// ─────────────────────── Exceptions ──────────────────────────────────────────

class DictionaryApiException implements Exception {
  const DictionaryApiException(this.message);
  final String message;
  @override
  String toString() => 'DictionaryApiException: $message';
}

class DictionaryNotFoundException extends DictionaryApiException {
  const DictionaryNotFoundException(super.message);
}

class DictionaryRateLimitException extends DictionaryApiException {
  const DictionaryRateLimitException()
    : super('Too many requests. Please wait a moment and try again.');
}

class DictionaryOfflineException implements Exception {
  const DictionaryOfflineException();
  @override
  String toString() => 'DictionaryOfflineException: no network';
}

class DictionaryAiUnavailableException implements Exception {
  const DictionaryAiUnavailableException();
  @override
  String toString() =>
      'DictionaryAiUnavailableException: AI key not configured';
}
