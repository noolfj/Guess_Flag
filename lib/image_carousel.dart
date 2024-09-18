import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'localization.dart'; // Подключаем файл с переводами

class ImageCarousel extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLanguage;

  ImageCarousel({required this.toggleTheme, required this.toggleLanguage});

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
    final String response =
        await rootBundle.loadString('assets/country_flags.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _flags = data.map((item) => {
        'flag': item['flag'] as String,
        'country': item['country'] as String,
        'country_ru': item['country_ru'] as String,
      }).toList();
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

  String countryName = _flags[_currentIndex]['country']!;
  if (Localizations.localeOf(context).languageCode == 'ru') {
    countryName = _flags[_currentIndex]['country_ru']!;
  }

  return Scaffold(
    appBar: AppBar(
      title: Text(
        AppLocalizations.of(context)?.translate('guess_flag') ?? 'GUESS FLAG',
        style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'TimesNewRoman',
            // fontStyle: FontStyle.italic
            ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.brightness_6,size: 30),
          onPressed: widget.toggleTheme,
        ),
        IconButton(
          icon: Icon(Icons.language,size: 30),
          onPressed: widget.toggleLanguage,
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
                      countryName,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'TimesNewRoman',
                          // fontStyle: FontStyle.italic
                          ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            '${AppLocalizations.of(context)?.translate('score') ?? 'Score'}: $_correctGuesses',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'TimesNewRoman',
                // fontStyle: FontStyle.italic
                ),
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
