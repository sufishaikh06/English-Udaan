import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/learning_models.dart';

class LearningRepository {
  const LearningRepository(this._loadAsset);

  static const twoLetterMinimum = 75;
  static const threeLetterMinimum = 100;
  static const threeLetterMaximum = 125;
  static const fourLetterMinimum = 125;
  static const fourLetterMaximum = 150;
  static const fiveLetterMinimum = 150;
  static const fiveLetterMaximum = 175;
  static const contentVersion = '0.1.0-sample';

  final Future<String> Function(String path) _loadAsset;

  factory LearningRepository.bundled() =>
      LearningRepository(rootBundle.loadString);

  Future<List<GrammarLesson>> loadGrammarLessons() async {
    final decoded = _decode(await _loadAsset('assets/content/grammar_sample.json'));
    if (decoded['section'] != 'grammar') {
      throw const FormatException('Invalid grammar section.');
    }
    final list = decoded['items'];
    if (list is! List || list.isEmpty) {
      throw const FormatException('Grammar content is empty.');
    }
    final lessons = list
        .map((item) => GrammarLesson.fromJson(_record(item)))
        .toList();
    _assertUnique(lessons.map((item) => item.id), 'grammar lesson IDs');
    _assertUnique(lessons.map((item) => item.order.toString()), 'grammar lesson orders');
    const requiredCategories = {
      'partsOfSpeech',
      'nouns',
      'pronouns',
      'verbs',
      'adjectives',
      'adverbs',
      'prepositions',
      'conjunctions',
      'articles',
      'tenses',
      'modals',
      'agreement',
      'activePassive',
      'directIndirect',
      'degrees',
      'sentenceStructure',
      'commonErrors',
    };
    final categories = lessons.map((item) => item.category).toSet();
    if (!categories.containsAll(requiredCategories)) {
      throw const FormatException('Grammar content is missing required categories.');
    }
    final levels = lessons.map((item) => item.level).toSet();
    if (!levels.containsAll({'beginner', 'elementary', 'intermediate', 'advanced'})) {
      throw const FormatException('Grammar content must include all levels.');
    }
    return lessons..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<List<SentenceLearningItem>> loadSentenceLearningItems() async {
    final decoded = _decode(
      await _loadAsset('assets/content/sentences_paragraphs_sample.json'),
    );
    if (decoded['section'] != 'sentences_paragraphs') {
      throw const FormatException('Invalid sentences and paragraphs section.');
    }
    final list = decoded['items'];
    if (list is! List || list.isEmpty) {
      throw const FormatException('Sentence and paragraph content is empty.');
    }
    final items = list
        .map((item) => SentenceLearningItem.fromJson(_record(item)))
        .toList();
    _assertUnique(items.map((item) => item.id), 'sentence/paragraph IDs');
    _assertUnique(items.map((item) => item.order.toString()), 'lesson orders');
    if (!items.any((item) => item.type == LearningContentType.smallSentence) ||
        !items.any((item) => item.type == LearningContentType.mediumSentence) ||
        !items.any((item) => item.type == LearningContentType.longSentence) ||
        !items.any((item) => item.type == LearningContentType.paragraph)) {
      throw const FormatException('All sentence and paragraph types are required.');
    }
    return items..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<List<AlphabetItem>> loadAlphabet() async {
    final decoded = _decode(
      await _loadAsset('assets/content/alphabet_sample.json'),
    );
    final items = decoded['items'];
    if (items is! List || items.length != 26) {
      throw const FormatException('Alphabet content must have 26 items.');
    }
    final alphabet = items
        .map((item) => AlphabetItem.fromJson(_record(item)))
        .toList();
    _assertUnique(alphabet.map((item) => item.id), 'alphabet IDs');
    return alphabet;
  }

  Future<List<VocabularyItem>> loadVocabulary({int wordLength = 2}) async {
    final decoded = _decode(
      await _loadAsset('assets/content/vocabulary_sample.json'),
    );
    final items = decoded['items'];
    if (items is! List || items.isEmpty) {
      throw const FormatException('Vocabulary is empty.');
    }
    final vocabulary = items
        .map((item) => VocabularyItem.fromJson(_record(item)))
        .toList();
    final section = vocabulary
        .where((item) => item.length == wordLength)
        .toList();
    if (wordLength == 2 && section.length < twoLetterMinimum) {
      throw FormatException(
        'Two-letter vocabulary must contain at least $twoLetterMinimum words.',
      );
    }
    if (wordLength == 3 &&
        (section.length < threeLetterMinimum ||
            section.length > threeLetterMaximum)) {
      throw FormatException(
        'Three-letter vocabulary must contain between $threeLetterMinimum and $threeLetterMaximum words.',
      );
    }
    if (wordLength == 4 &&
        (section.length < fourLetterMinimum ||
            section.length > fourLetterMaximum)) {
      throw FormatException(
        'Four-letter vocabulary must contain between $fourLetterMinimum and $fourLetterMaximum words.',
      );
    }
    if (wordLength == 5 &&
        (section.length < fiveLetterMinimum ||
            section.length > fiveLetterMaximum)) {
      throw FormatException(
        'Five-letter vocabulary must contain between $fiveLetterMinimum and $fiveLetterMaximum words.',
      );
    }
    if (section.any((item) => item.word.length != wordLength)) {
      throw FormatException(
        'Vocabulary words must contain exactly $wordLength letters.',
      );
    }
    _assertUnique(section.map((item) => item.id), 'vocabulary IDs');
    _assertUnique(section.map((item) => item.word), 'vocabulary words');
    return section;
  }

  Future<List<PictureCategory>> loadPictureCategories() async {
    final decoded = _decode(
      await _loadAsset('assets/content/picture_learning_sample.json'),
    );
    final list = decoded['categories'];
    if (list is! List || list.isEmpty) {
      throw const FormatException('Picture categories are empty.');
    }
    final categories = list
        .map((c) => PictureCategory.fromJson(_record(c)))
        .toList();
    _assertUnique(categories.map((c) => c.id), 'picture category IDs');
    return categories;
  }

  Future<List<PictureItem>> loadPictureItems({String? categoryId}) async {
    final decoded = _decode(
      await _loadAsset('assets/content/picture_learning_sample.json'),
    );
    final itemsList = decoded['items'];
    if (itemsList is! List) {
      throw const FormatException('Picture items must be a list.');
    }
    final allItems = itemsList
        .map((item) => PictureItem.fromJson(_record(item)))
        .toList();
    if (categoryId != null) {
      final filtered = allItems
          .where((i) => i.categoryId == categoryId)
          .toList();
      _assertUnique(filtered.map((item) => item.id), 'picture item IDs');
      return filtered;
    }
    _assertUnique(allItems.map((item) => item.id), 'picture item IDs');
    return allItems;
  }

  Map<String, dynamic> _decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['version'] != contentVersion) {
      throw const FormatException('Unsupported learning content version.');
    }
    return decoded;
  }

  Map<String, dynamic> _record(Object? item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Invalid content record.');
    }
    return item;
  }

  void _assertUnique(Iterable<String> values, String label) {
    final items = values.toList();
    if (items.toSet().length != items.length) {
      throw FormatException('Duplicate $label.');
    }
  }
}
