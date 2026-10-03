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
      child: MaterialApp(
        title: 'Radio Voyage',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const RadioVoyageScreen(),
      ),
    );
  }
}
