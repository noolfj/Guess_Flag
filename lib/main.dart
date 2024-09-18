import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'image_carousel.dart';
import 'localization.dart'; // Импортируем локализацию

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = Locale('en'); // Начальный язык - английский

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? Locale('ru') : Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: [
        Locale('en', ''), // Английский
        Locale('ru', ''), // Русский
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        const AppLocalizationsDelegate(), // Наш кастомный делегат
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[300],
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[750],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[750],
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      home: ImageCarousel(toggleTheme: _toggleTheme, toggleLanguage: _toggleLanguage),
    );
  }
}
