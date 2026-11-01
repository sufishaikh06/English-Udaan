enum LearningContentType { smallSentence, mediumSentence, longSentence, paragraph }

class SentenceLearningItem {
  const SentenceLearningItem({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.order,
    required this.english,
    required this.urdu,
    required this.ttsText,
  });

  final String id;
  final LearningContentType type;
  final String difficulty;
  final int order;
  final String english;
  final String urdu;
  final String ttsText;

  factory SentenceLearningItem.fromJson(Map<String, dynamic> json) {
    final typeString = requiredString(json, 'type');
    final type = LearningContentType.values.where((item) => item.name == typeString);
    if (type.isEmpty) throw const FormatException('Unsupported learning content type.');
    final order = json['order'];
    if (order is! int || order < 1) throw const FormatException('Invalid lesson order.');
    final difficulty = requiredString(json, 'difficulty');
    if (!{'beginner', 'developing', 'intermediate'}.contains(difficulty)) {
      throw const FormatException('Invalid lesson difficulty.');
    }
    return SentenceLearningItem(
      id: requiredString(json, 'id'),
      type: type.first,
      difficulty: difficulty,
      order: order,
      english: requiredString(json, 'english'),
      urdu: requiredString(json, 'urdu'),
      ttsText: requiredString(json, 'ttsText'),
    );
  }
}

class GrammarExample {
  const GrammarExample({
    required this.english,
    required this.urdu,
    required this.note,
    required this.ttsText,
  });

  final String english;
  final String urdu;
  final String note;
  final String ttsText;

  factory GrammarExample.fromJson(Map<String, dynamic> json) => GrammarExample(
    english: requiredString(json, 'english'),
    urdu: requiredString(json, 'urdu'),
    note: requiredString(json, 'note'),
    ttsText: requiredString(json, 'ttsText'),
  );
}

class GrammarCorrection {
  const GrammarCorrection({
    required this.incorrect,
    required this.correct,
    required this.urdu,
  });

  final String incorrect;
  final String correct;
  final String urdu;

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) => GrammarCorrection(
    incorrect: requiredString(json, 'incorrect'),
    correct: requiredString(json, 'correct'),
    urdu: requiredString(json, 'urdu'),
  );
}

class GrammarLesson {
  const GrammarLesson({
    required this.id,
    required this.level,
    required this.category,
    required this.difficulty,
    required this.order,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.explanationEnglish,
    required this.explanationUrdu,
    required this.examples,
    required this.corrections,
    required this.ttsText,
  });

  final String id;
  final String level;
  final String category;
  final String difficulty;
  final int order;
  final String titleEnglish;
  final String titleUrdu;
  final String explanationEnglish;
  final String explanationUrdu;
  final List<GrammarExample> examples;
  final List<GrammarCorrection> corrections;
  final String ttsText;

  factory GrammarLesson.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    if (order is! int || order < 1) throw const FormatException('Invalid grammar lesson order.');
    final level = requiredString(json, 'level');
    if (!{'beginner', 'elementary', 'intermediate', 'advanced'}.contains(level)) {
      throw const FormatException('Invalid grammar level.');
    }
    final difficulty = requiredString(json, 'difficulty');
    if (!{'beginner', 'developing', 'intermediate', 'advanced'}.contains(difficulty)) {
      throw const FormatException('Invalid grammar difficulty.');
    }
    final examplesList = json['examples'];
    if (examplesList is! List || examplesList.isEmpty) {
      throw const FormatException('Grammar lessons require examples.');
    }
    final correctionsList = json['corrections'];
    if (correctionsList is! List) {
      throw const FormatException('Grammar corrections must be a list.');
    }
    return GrammarLesson(
      id: requiredString(json, 'id'),
      level: level,
      category: requiredString(json, 'category'),
      difficulty: difficulty,
      order: order,
      titleEnglish: requiredString(json, 'titleEnglish'),
      titleUrdu: requiredString(json, 'titleUrdu'),
      explanationEnglish: requiredString(json, 'explanationEnglish'),
      explanationUrdu: requiredString(json, 'explanationUrdu'),
      examples: examplesList.map((item) => GrammarExample.fromJson(_requiredMap(item))).toList(),
      corrections: correctionsList.map((item) => GrammarCorrection.fromJson(_requiredMap(item))).toList(),
      ttsText: requiredString(json, 'ttsText'),
    );
  }
}

class AlphabetItem {
  const AlphabetItem({
    required this.id,
    required this.letter,
    required this.lowercase,
    required this.englishExample,
    required this.urduMeaning,
    required this.ttsText,
  });

  final String id;
  final String letter;
  final String lowercase;
  final String englishExample;
  final String urduMeaning;
  final String ttsText;

  factory AlphabetItem.fromJson(Map<String, dynamic> json) => AlphabetItem(
    id: requiredString(json, 'id'),
    letter: requiredString(json, 'letter'),
    lowercase: requiredString(json, 'lowercase'),
    englishExample: requiredString(json, 'englishExample'),
    urduMeaning: requiredString(json, 'urduMeaning'),
    ttsText: requiredString(json, 'ttsText'),
  );
}

class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.word,
    required this.length,
    required this.category,
    required this.difficulty,
    required this.urduMeaning,
    required this.example,
    required this.ttsText,
    required this.version,
  });

  final String id;
  final String word;
  final int length;
  final String category;
  final String difficulty;
  final String urduMeaning;
  final String example;
  final String ttsText;
  final String version;

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    final word = requiredString(json, 'word').toLowerCase();
    final length = json['length'];
    if (length is! int || length != word.length) {
      throw const FormatException('Vocabulary length must match the word.');
    }
    return VocabularyItem(
      id: requiredString(json, 'id'),
      word: word,
      length: length,
      category: requiredString(json, 'category'),
      difficulty: requiredString(json, 'difficulty'),
      urduMeaning: requiredString(json, 'urduMeaning'),
      example: requiredString(json, 'example'),
      ttsText: requiredString(json, 'ttsText'),
      version: requiredString(json, 'version'),
    );
  }

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return word.contains(needle) ||
        urduMeaning.contains(query.trim()) ||
        example.toLowerCase().contains(needle);
  }
}

enum ImageSourceType { localAsset, remoteUrl }

class PictureItem {
  const PictureItem({
    required this.id,
    required this.categoryId,
    required this.english,
    required this.urdu,
    required this.imageSourceType,
    this.localAssetPath,
    this.remoteUrl,
    this.example,
    required this.ttsText,
    required this.version,
  });

  final String id;
  final String categoryId;
  final String english;
  final String urdu;
  final ImageSourceType imageSourceType;
  final String? localAssetPath;
  final String? remoteUrl;
  final String? example;
  final String ttsText;
  final String version;

  factory PictureItem.fromJson(Map<String, dynamic> json) {
    final sourceTypeStr = requiredString(json, 'imageSourceType');
    final sourceType = sourceTypeStr == 'remoteUrl'
        ? ImageSourceType.remoteUrl
        : ImageSourceType.localAsset;

    return PictureItem(
      id: requiredString(json, 'id'),
      categoryId: requiredString(json, 'categoryId'),
      english: requiredString(json, 'english'),
      urdu: requiredString(json, 'urdu'),
      imageSourceType: sourceType,
      localAssetPath: json['localAssetPath'] as String?,
      remoteUrl: json['remoteUrl'] as String?,
      example: json['example'] as String?,
      ttsText: json['ttsText'] as String? ?? requiredString(json, 'english'),
      version: requiredString(json, 'version'),
    );
  }

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return english.toLowerCase().contains(needle) ||
        urdu.contains(query.trim()) ||
        (example != null && example!.toLowerCase().contains(needle));
  }
}

class PictureCategory {
  const PictureCategory({
    required this.id,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.iconName,
    required this.itemCount,
  });

  final String id;
  final String titleEnglish;
  final String titleUrdu;
  final String iconName;
  final int itemCount;

  factory PictureCategory.fromJson(Map<String, dynamic> json) {
    return PictureCategory(
      id: requiredString(json, 'id'),
      titleEnglish: requiredString(json, 'titleEnglish'),
      titleUrdu: requiredString(json, 'titleUrdu'),
      iconName: requiredString(json, 'iconName'),
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }
}

Map<String, dynamic> _requiredMap(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid nested content record.');
  }
  return value;
}

String requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing $key');
  }
  return value.trim();
}
