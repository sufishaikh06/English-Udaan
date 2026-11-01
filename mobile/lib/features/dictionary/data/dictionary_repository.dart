import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dictionary_models.dart';
import 'dictionary_api_service.dart';

// ─────────────────────── Service provider ────────────────────────────────────

final _dictionaryApiServiceProvider = Provider<DictionaryApiService>(
  (ref) => DictionaryApiService(),
);

// ─────────────────────── Notifier ────────────────────────────────────────────

/// Manages dictionary lookup state for the [DictionaryScreen].
class DictionaryNotifier extends Notifier<DictionaryLookupState> {
  @override
  DictionaryLookupState build() => const DictionaryIdle();

  Future<void> lookup(String query, {String sourceLanguage = 'ur'}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const DictionaryIdle();
      return;
    }

    state = const DictionaryLoading();

    try {
      final service = ref.read(_dictionaryApiServiceProvider);
      final result = await service.lookup(
        query: trimmed,
        sourceLanguage: sourceLanguage,
        targetLanguage: sourceLanguage == 'ur' ? 'en' : 'ur',
      );
      state = DictionarySuccess(result);
    } on DictionaryNotFoundException catch (e) {
      state = DictionaryEmpty(e.message.isNotEmpty ? trimmed : trimmed);
    } on DictionaryAiUnavailableException {
      state = const DictionaryError(
        'Live AI lookup is not available — database results only.',
        aiUnavailable: true,
      );
    } on DictionaryOfflineException {
      state = const DictionaryError(
        'Could not connect to the server. Check your internet connection.',
        isOffline: true,
      );
    } on DictionaryRateLimitException catch (e) {
      state = DictionaryError(e.message);
    } on DictionaryApiException catch (e) {
      state = DictionaryError(e.message);
    } on Object catch (e) {
      state = DictionaryError('An unexpected error occurred: $e');
    }
  }

  void clear() {
    state = const DictionaryIdle();
  }
}

final dictionaryProvider =
    NotifierProvider<DictionaryNotifier, DictionaryLookupState>(
      DictionaryNotifier.new,
    );
