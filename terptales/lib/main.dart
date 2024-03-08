import 'package:flutter/material.dart';
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

  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
        itemCount: bookTitles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bookTitles[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PDFViewerPage(),
                  settings: RouteSettings(arguments: bookUrls[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('TerpTales')),
//       body: ListView.builder(
//         itemCount: bookTitles.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(bookTitles[index]),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PDFViewerPage(),
//                   settings: RouteSettings(arguments: bookUrls[index]))
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }