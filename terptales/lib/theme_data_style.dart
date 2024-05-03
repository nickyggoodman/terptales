/* This file defines a `ThemeDataStyle` class containing static instances 
of `ThemeData` for light and dark themes. The `light` theme uses light 
colors and brightness, while the `dark` theme uses dark colors and 
brightness. These themes are configured with specific color schemes for 
backgrounds, primary, and secondary colors. The `useMaterial3` property 
indicates the usage of Material Design 3.0 components. This class provides 
convenient access to predefined theme data styles for use throughout the 
application.
-Justinah Bashua*/

import 'package:flutter/material.dart';

class ThemeDataStyle {
  
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Colors.grey.shade100,
      primary: const Color.fromARGB(255, 135, 249, 4),
      secondary: const Color.fromARGB(255, 151, 198, 98),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      primary: const Color.fromRGBO(100, 164, 96, 1.0),
      secondary: const Color.fromRGBO(37,62,35, 1.0),
    ),
  );

}