import 'package:english_udaan/core/services/speech_service.dart';
import 'package:english_udaan/features/learning/presentation/learning_screens.dart';
import 'package:english_udaan/main.dart';
import 'package:english_udaan/shared/widgets/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSpeechService implements SpeechService {
  @override
  Future<void> speak(String text) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home alphabet card opens the A-Z overview', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EnglishUdaanApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('حروف تہجی'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AlphabetScreen), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('Home learn words card opens the vocabulary list', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EnglishUdaanApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final card = find.widgetWithText(LearningCard, 'الفاظ سیکھیں');
    await tester.scrollUntilVisible(
      card,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(VocabularyScreen), findsOneWidget);
    expect(find.text('دو حرفی الفاظ'), findsOneWidget);
  });

  testWidgets('Vocabulary screen switches sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: VocabularyScreen(speechService: FakeSpeechService()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('am'), findsWidgets);

    await tester.tap(find.text('۳'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('تین حرفی الفاظ'), findsOneWidget);
    expect(find.text('act'), findsWidgets);

    await tester.tap(find.text('۴'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('چار حرفی الفاظ'), findsOneWidget);
    expect(find.text('able'), findsWidgets);

    await tester.tap(find.text('۵'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('پانچ حرفی الفاظ'), findsOneWidget);
    expect(find.text('about'), findsWidgets);
  });

  testWidgets('vocabulary search filters the list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: VocabularyScreen(speechService: FakeSpeechService()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('کوئی نتیجہ نہیں'), findsOneWidget);
  });

  testWidgets('completing vocabulary persists its completion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: VocabularyScreen(speechService: FakeSpeechService()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final button = find.widgetWithText(ElevatedButton, 'سبق مکمل کریں');
    await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('سبق مکمل ہو گیا'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('lesson.vocabulary.two-letter.complete'), true);
  });
}
