import 'package:english_udaan/main.dart';
import 'package:english_udaan/shared/widgets/app_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts in Urdu with RTL shell labels and branded home', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EnglishUdaanApp()));
    await tester.pumpAndSettle();

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('سیکھیں'), findsOneWidget);
    expect(find.text('پریکٹس'), findsOneWidget);
    expect(find.text('پیش رفت'), findsOneWidget);
    expect(find.text('پروفائل'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('settings switches interface to English LTR', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EnglishUdaanApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });
}
