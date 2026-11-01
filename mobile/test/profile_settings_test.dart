import 'package:english_udaan/core/services/speech_service.dart';
import 'package:english_udaan/main.dart';
import 'package:english_udaan/features/profile/presentation/profile_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('speech preferences safely validate stored rate', () {
    expect(
      SpeechPreferences.fromStorage(rate: 99).rate,
      SpeechPreferences.maxRate,
    );
    expect(
      SpeechPreferences.fromStorage(rate: -1).rate,
      SpeechPreferences.minRate,
    );
    expect(
      SpeechPreferences.fromStorage(rate: double.nan).rate,
      SpeechPreferences.defaultRate,
    );
    expect(SpeechPreferences.fromStorage().enabled, isTrue);
  });

  test('speech preferences persist and restore', () async {
    final container = ProviderContainer();
    container.read(preferencesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final controller = container.read(preferencesProvider.notifier);
    await controller.setSpeechEnabled(false);
    await controller.setSpeechRate(0.7);

    final stored = await SharedPreferences.getInstance();
    expect(stored.getBool(SpeechPreferences.enabledKey), isFalse);
    expect(stored.getDouble(SpeechPreferences.rateKey), 0.7);
    container.dispose();

    SharedPreferences.setMockInitialValues({
      SpeechPreferences.enabledKey: false,
      SpeechPreferences.rateKey: 0.7,
    });
    final restored = ProviderContainer();
    restored.read(preferencesProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(restored.read(preferencesProvider).speechEnabled, isFalse);
    expect(restored.read(preferencesProvider).speechRate, 0.7);
    restored.dispose();
  });

  testWidgets('profile shows accurate local-only account status', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProfileScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('مقامی صارف'), findsOneWidget);
    expect(find.text('لاگ آؤٹ'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('audio preferences can be changed from audio settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AudioSettingsScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(SpeechPreferences.enabledKey), isFalse);
  });
}
