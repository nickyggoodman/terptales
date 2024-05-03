/*This file defines a `ThemeProvider` class responsible for managing the 
theme data style of the application. It utilizes `ChangeNotifier` from 
Flutter to notify listeners when the theme data changes. The `ThemeProvider` 
class maintains a `_themeDataStyle` property representing the current theme 
data style, which defaults to `light`. It provides getters and setters for 
accessing and updating the theme data style. Additionally, it includes a 
`changeTheme()` method to toggle between `light` and `dark` theme data styles.
- Justinah Bashua */

import 'package:flutter/material.dart';

import 'package:terptales/theme_data_style.dart';

class ThemeProvider extends ChangeNotifier {

  ThemeData _themeDataStyle = ThemeDataStyle.light;

  ThemeData get themeDataStyle => _themeDataStyle;

  set themeDataStyle (ThemeData themeData) {
   _themeDataStyle = themeData;
   notifyListeners();
  }

  void changeTheme() {
    if (_themeDataStyle == ThemeDataStyle.light) {
      themeDataStyle = ThemeDataStyle.dark;
    } else {
      themeDataStyle = ThemeDataStyle.light;
    }
  }
  
}