import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:terptales/PDFViewerPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookListPage(),
    );
  }
}

class BookListPage extends StatelessWidget {
  final List<String> bookTitles = [
    'Using the Bash Command Line',
    'A General Systems Handbook',
    'Linux Networking Basics'
    // Add more book titles as needed
  ];

  final List<String> bookUrls = [
    'https://www.cs.umd.edu/~mmarsh/books/cmdline.pdf',
    'https://www.cs.umd.edu/~mmarsh/books/tools.pdf',
    'https://www.cs.umd.edu/~mmarsh/books/cmsc389z.pdf',
    // Add corresponding URLs for each book
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TerpTales')),
      body: ListView.builder(
        itemCount: bookTitles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bookTitles[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerPage(pdfUrl: bookUrls[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const HomePage(),
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)
//       ),
//     );
//   }
// }

// /* 
// followed a guide from youtube:) https://www.youtube.com/watch?v=XSheN4Lkhpc
// there is also useful documentation here: https://docs.flutter.dev/cookbook/design/tabs
// */
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     // should probably use some tuples here if that's possible in Dart
//     final terpIcons = [Icons.sledding, Icons.snowshoeing,]; 
//     final items = ['Using the Bash Command Line', 'A general Systems Handbook', 'Linux Networking Basics',]; 
//     return ListView.builder(
//       itemCount: terpIcons.length,
//       itemBuilder:(context, index){
//         return ListTile(
//           title: Text(items[index]),
//           leading: (Icon(terpIcons[index])),
//         );
//       },
//     );

//   }
// }
