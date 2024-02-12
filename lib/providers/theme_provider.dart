import 'package:flutter/material.dart';

//datoteka kjer določamo barvno temo in njene barve

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  //prvotna barvna tema

  bool get isDarkMode => themeMode == ThemeMode.dark;

  bool _darkMode = false;
  void toggleTheme() {
    //spreminjanje barve teme
    _darkMode = !_darkMode;
    //spremenimo temo
    themeMode = _darkMode ? ThemeMode.dark : ThemeMode.light;
    //shranimo spremembo

    notifyListeners();
    //obvestimo ves datotke o spremembi
  }
}

//lasnosti temne teme
class MyThemes {
  static final darkTheme = ThemeData.dark().copyWith(
    //določanje barv
    scaffoldBackgroundColor: Color(0xFF000000),
    primaryColor: const Color(0xFF000000),
    backgroundColor: Color(0xFFFFFFFF),
    secondaryHeaderColor: const Color(0xFFFF9800),
    iconTheme: IconThemeData(
      //prvotna barva ikon
      color: const Color(0xFFFFFFFF),
    ),
    textTheme: TextTheme(
      //barve in velikosti besedil
      headline1: TextStyle(
        fontSize: 30,
        color: const Color(0xFFFF9800),
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: 18,
        color: const Color(0xFFFF9800),
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        fontSize: 18,
        color: const Color(0xFFFFFFFF),
      ),
      bodyText2: TextStyle(
        fontSize: 15,
        color: const Color(0xFFFFFFFF).withOpacity(0.64),
      ),
    ),
  );

  //lasnosti svetle teme
  static final lightTheme = ThemeData.light().copyWith(
    //določanje barv
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    primaryColor: const Color(0xFFFFFFFF),
    backgroundColor: Color(0xFF000000),
    secondaryHeaderColor: const Color(0xFFFF9800),
    iconTheme: IconThemeData(
      //prvotna barva ikon
      color: const Color(0xFFFFFFFF),
    ),
    textTheme: TextTheme(
      //barve in velikosti besedil
      headline1: TextStyle(
        fontSize: 30,
        color: const Color(0xFFFF9800),
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: 18,
        color: const Color(0xFFFF9800),
        fontWeight: FontWeight.bold,
      ),
      bodyText1: TextStyle(
        fontSize: 18,
        color: const Color(0xFF000000),
      ),
      bodyText2: TextStyle(
        fontSize: 15,
        color: const Color(0xFF000000).withOpacity(0.64),
      ),
    ),
  );
}
