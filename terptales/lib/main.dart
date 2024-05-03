// import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:terptales/book_list.dart';
import 'package:terptales/settings_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
// import 'package:terptales/theme_data_style.dart';
import 'package:terptales/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // // Initialize settings
    Settings.init();
  runApp(
    //Provider added by justinah B. to work with light mode, dark mode
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dark/Light',
      theme: Provider.of<ThemeProvider>(context).themeDataStyle, //added by justinah
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
              'TerpTales',
              textAlign: TextAlign.center,
              style: GoogleFonts.taprom(
                textStyle: const TextStyle(fontStyle: FontStyle.italic,fontSize: 30),
            ),),
            const SizedBox(width: 10),
      const Icon(
        Icons.book,
        size: 30,
        color: Colors.red,
      ),
    ],
          ),
          
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            LayoutBuilder(
              builder: (context, constraints) => const BookList(),
            ),
             LayoutBuilder(
              builder: (context, constraints) => const SettingsPage(),
             ),
          ],
        ),
      ),
    );
  }
}
