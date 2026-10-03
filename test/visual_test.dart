import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:radio_voyage/core/theme/app_theme.dart';
import 'package:radio_voyage/presentation/providers/radio_globe_provider.dart';
import 'package:radio_voyage/presentation/screens/radio_voyage_screen.dart';

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await inter.load();
  });

  Future<void> renderAt(
    WidgetTester tester,
    Size size,
    String goldenName,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RadioGlobeProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const RadioVoyageScreen(),
        ),
      ),
    );
    // Texture decoding runs outside the fake clock. Wait for the actual
    // equirectangular surface rather than taking a loading-state screenshot.
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pump(const Duration(milliseconds: 250));
      final provider = Provider.of<RadioGlobeProvider>(
        tester.element(find.byType(RadioVoyageScreen)),
        listen: false,
      );
      if (provider.globeController.surfaceProcessed != null &&
          provider.selectedStation != null) {
        await tester.pump(const Duration(milliseconds: 250));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 2)),
        );
        for (var frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        break;
      }
    }
    expect(find.byType(RadioVoyageScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(RadioVoyageScreen),
      matchesGoldenFile('goldens/$goldenName.png'),
    );
    // Flush the globe package's zero-duration post-layout timers before the
    // test binding verifies pending async work.
    final provider = Provider.of<RadioGlobeProvider>(
      tester.element(find.byType(RadioVoyageScreen)),
      listen: false,
    );
    provider.globeController.points = [];
    provider.globeController.notifyListeners();
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets(
      'Radio Voyage matches the 390 x 844 reference viewport',
      (tester) =>
          renderAt(tester, const Size(390, 844), 'radio_voyage_390x844'));

  testWidgets(
      'Radio Voyage remains overflow-free on a compact viewport',
      (tester) =>
          renderAt(tester, const Size(360, 740), 'radio_voyage_360x740'));
}
