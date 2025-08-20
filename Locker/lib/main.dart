import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';

void main() => runApp(const LockerApp());

class LockerApp extends StatelessWidget {
  const LockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locker',
      theme: AppTheme.darkTheme,
      themeMode: AppTheme.themeMode,
      home: const HomeScreen(),
    );
  }
}
