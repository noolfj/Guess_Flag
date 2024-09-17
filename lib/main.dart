import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[300], 
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[300], 
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), 
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[750],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[750], 
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      home: ImageCarousel(toggleTheme: _toggleTheme),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final VoidCallback toggleTheme;

  ImageCarousel({required this.toggleTheme});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  bool _showCountryName = false;
  int _correctGuesses = 0;
  List<Map<String, String>> _flags = [];
  Set<int> _displayedIndices = Set<int>();

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    try {
      final String response = await rootBundle.loadString('assets/country_flags.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _flags = data
            .map((item) => {
                  'flag': item['flag'] as String,
                  'country': item['country'] as String,
                })
            .toList();
        _currentIndex = 0;
        _displayedIndices.clear(); 
      });
      _nextImage(); 
    } catch (e) {
      print("Error loading or parsing JSON: $e");
    }
  }

  void _nextImage() {
    setState(() {
      if (_displayedIndices.length >= _flags.length) {
        _displayedIndices.clear(); 
      }

      Random random = Random();
      int newIndex;

      do {
        newIndex = random.nextInt(_flags.length);
      } while (_displayedIndices.contains(newIndex));

      _displayedIndices.add(newIndex);
      _currentIndex = newIndex;
      _showCountryName = false;
    });
  }

  void _correctGuess() {
    setState(() {
      _correctGuesses++;
      _nextImage();
    });
  }

  void _showFlagName() {
    setState(() {
      _showCountryName = true;
    });
  }

  void _resetGame() {
    setState(() {
      _correctGuesses = 0;
      _displayedIndices.clear();
      _nextImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_flags.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GUESS FLAG',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              fontFamily: 'TimesNewRoman',
              fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6, size: 30),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showFlagName,
              child: Column(
                children: [
                  SizedBox(height: 250),
                  SizedBox(
                    width: 320,
                    height: 200,
                    child: Image.asset(
                      _flags[_currentIndex]['flag']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_showCountryName)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _flags[_currentIndex]['country']!,
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'TimesNewRoman',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Score: $_correctGuesses',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TimesNewRoman',
                  fontStyle: FontStyle.italic),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _correctGuess,
                  style: buttonStyle.copyWith(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: Icon(
                    Icons.check_circle_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: _resetGame,
                  style: buttonStyle.copyWith(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Icon(
                    Icons.refresh,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextImage,
                  style: buttonStyle.copyWith(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orange),
                  ),
                  child: Icon(
                    Icons.next_plan_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
  textStyle: TextStyle(fontSize: 20),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
);
