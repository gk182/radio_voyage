import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_voyage/core/theme/app_theme.dart';
import 'package:radio_voyage/main.dart';
import 'package:radio_voyage/presentation/providers/radio_globe_provider.dart';
import 'package:radio_voyage/presentation/screens/radio_voyage_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme & AppPalette', () {
    test('Dark and Light themes instantiate correctly with proper brightness', () {
      final dark = AppTheme.darkTheme;
      final light = AppTheme.lightTheme;

      expect(dark.brightness, Brightness.dark);
      expect(light.brightness, Brightness.light);

      final darkPalette = dark.extension<AppPalette>();
      final lightPalette = light.extension<AppPalette>();

      expect(darkPalette, isNotNull);
      expect(lightPalette, isNotNull);
      expect(darkPalette!.isDark, isTrue);
      expect(lightPalette!.isDark, isFalse);
    });

    test('CockpitAccent applies primary accent color correctly across palettes', () {
      for (final accent in CockpitAccent.values) {
        final dark = AppTheme.buildTheme(
          brightness: Brightness.dark,
          accent: accent,
        );
        final light = AppTheme.buildTheme(
          brightness: Brightness.light,
          accent: accent,
        );

        final darkPal = dark.extension<AppPalette>()!;
        final lightPal = light.extension<AppPalette>()!;

        expect(darkPal.accent, accent.primary);
        expect(lightPal.accent, accent.primary);
      }
    });
  });

  group('RadioGlobeProvider Theme Management', () {
    test('Can change theme mode and toggle between dark and light', () {
      final provider = RadioGlobeProvider();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);

      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, isFalse);

      provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, ThemeMode.system);

      provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('Can change CockpitAccent independently', () {
      final provider = RadioGlobeProvider();

      expect(provider.accent, CockpitAccent.solar);

      provider.setCockpitAccent(CockpitAccent.cyan);
      expect(provider.accent, CockpitAccent.cyan);

      provider.setCockpitAccent(CockpitAccent.emerald);
      expect(provider.accent, CockpitAccent.emerald);
    });

    test('Syncs Earth texture when enabled', () {
      final provider = RadioGlobeProvider();

      expect(provider.syncGlobeWithTheme, isTrue);
      expect(provider.isNightMode, isTrue);

      provider.setThemeMode(ThemeMode.light);
      expect(provider.isNightMode, isFalse);

      provider.setThemeMode(ThemeMode.dark);
      expect(provider.isNightMode, isTrue);
    });
  });

  testWidgets('RadioVoyageApp boots up and renders with dynamic theme provider', (tester) async {
    await tester.pumpWidget(const RadioVoyageApp());
    expect(find.byType(RadioVoyageApp), findsOneWidget);
    expect(find.byType(RadioVoyageScreen), findsOneWidget);
  });
}
