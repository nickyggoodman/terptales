import 'dart:io';

import 'package:terptales/pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:snowglobes24/flutter_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme:
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
    );
  }
}

/* 

*/
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    // from Dr. Marsh's site https://www.cs.umd.edu/~mmarsh/books.html
    final bookUrls = [
      'https://www.cs.umd.edu/~mmarsh/books/cmdline.pdf',
      'https://www.cs.umd.edu/~mmarsh/books/tools.pdf'
      'https://www.cs.umd.edu/~mmarsh/books/cmsc389z.pdf'
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terptales"),
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("book"),
            leading: (Icon(Icons.book)),
            onTap: () async {
              final url = bookUrls[index];
              final file = await PDFApi.loadNetwork(url);
              openPDF(context, file);
            }
          );
        },
      ),
    );
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );

}
