// import 'dart:io';
// import 'dart:ui';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:path/path.dart';
// import 'package:terptales/main.dart'; 
// import 'package:terptales/icon_widget.dart';
import 'faq_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:terptales/theme_data_style.dart';
import 'package:terptales/theme_provider.dart';
import 'package:provider/provider.dart';




class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SettingsGroup(
                title: 'Settings',
                children: <Widget>[
                  const FAQPage(),
                  buildCustomThemeSwitch(context),//ADDED BY JUSTINAH
                ],
              ),
            ],
          ),
        ),
      );

      

/*Widget that builds a customizable theme switcher UI, displaying the current
theme (dark or light) and allowing the user to toggle between them. It fetches
the current theme state from the theme_provider.dart file using Provider.of, and updates
the theme state when the switch is toggled.
- Justinah Bashua*/

  Widget buildCustomThemeSwitch(BuildContext context) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        Provider.of<ThemeProvider>(context).themeDataStyle == ThemeDataStyle.dark
            ? 'Dark Theme'
            : 'Light Theme',
        style: const TextStyle(fontSize: 25.0),
      ),
      const SizedBox(height: 10.0),
      Transform.scale(
        scale: 1.4,
        child: Switch(
          value: Provider.of<ThemeProvider>(context).themeDataStyle == ThemeDataStyle.dark
              ? true
              : false,
          onChanged: (isOn) {
            Provider.of<ThemeProvider>(context, listen: false).changeTheme();
          },
        ),
      ),
    ],
  ),
);

}
