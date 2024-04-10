import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:terptales/main.dart'; // Ensure this import is correct and necessary
import 'icon_widget.dart';
import 'faq_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';




class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const keyDarkMode = 'key-dark-mode';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const keyDarkMode = 'key-dark-mode';

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
                  buildTheme(),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildTheme() => SwitchSettingsTile(
        settingKey: keyDarkMode,
        leading: const IconWidget(
          icon: Icons.dark_mode,
          color: Color(0xFF642ef3),
        ),
        title: 'Light/Dark Mode',
        onChange: (_) {},
      );
}
