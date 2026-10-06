import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/radio_globe_provider.dart';
import 'presentation/screens/radio_voyage_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RadioVoyageApp());
}

class RadioVoyageApp extends StatelessWidget {
  const RadioVoyageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioGlobeProvider(),
      child: Selector<RadioGlobeProvider,
          ({ThemeMode themeMode, CockpitAccent accent})>(
        selector: (_, provider) =>
            (themeMode: provider.themeMode, accent: provider.accent),
        builder: (context, settings, child) {
          final darkTheme = AppTheme.buildTheme(
            brightness: Brightness.dark,
            accent: settings.accent,
          );
          final lightTheme = AppTheme.buildTheme(
            brightness: Brightness.light,
            accent: settings.accent,
          );

          return MaterialApp(
            title: 'Radio Voyage',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settings.themeMode,
            home: child,
          );
        },
        child: const RadioVoyageScreen(),
      ),
    );
  }
}
