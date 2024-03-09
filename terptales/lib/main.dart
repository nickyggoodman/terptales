import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// going off of the example from https://pub.dev/packages/flutter_pdfview/example
class _MyAppState extends State<MyApp> {
  
  String cmdlinepath = "";
  String cmsc389zpath = "";
  String toolspath = "";

  // the way I understand this, is that the pdf needs to be loaded to the device's OS.
  @override
  void initState(){
    super.initState(); //gotta be honest, i don't know what this does yet.
    fromAsset('assets/cmdline.pdf', 'cmdline.pdf').then((f) {
      setState(() {
        cmdlinepath = f.path;
      });
    });
    fromAsset('assets/cmsc389z.pdf', 'cmsc389z.pdf').then((f) {
      setState(() {
        cmsc389zpath = f.path;
      });
    });
    fromAsset('assets/tools.pdf', 'tools.pdf').then((f) {
      setState(() {
        toolspath = f.path;
      });
    });
    // we can try directly from a url later...
  }
  
  // retrieves the jaunt from the asset
  // https://docs.flutter.dev/cookbook/persistence/reading-writing-files path_provider
  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terptales',
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(title: const Text ('Terptales')),
        body: ListView.builder(
        itemCount: 3, //THIS IS HARD CODED - FIX LATER
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("[book title]"), // THIS IS HARD CODED - FIX LATER
            leading: const Icon(Icons.book),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // FIX - LOOP THROUGH EVERY PATH, NOT JUST cmdlinepath.
                  builder: (context) => PDFScreen(path: cmdlinepath),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}

// this will be our PDF page
// again, pull this code from https://pub.dev/packages/flutter_pdfview/example
class PDFScreen extends StatefulWidget {
  final String? path;

  PDFScreen({Key? key, this.path}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("[book name]"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path, //gets the path of the book from the widget
            enableSwipe: true, 
            swipeHorizontal: true, // like a book
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!, //???
            fitPolicy: FitPolicy.BOTH, //???
            preventLinkNavigation:
              false,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController PDFViewController) {
              _controller.complete(PDFViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
            ? !isReady
              ? Center(
                  child: CircularProgressIndicator(),
              )
              : Container()
            : Center(
              child: Text(errorMessage),
            )
        ],
      ),
    );
  }

}

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final bookUrls = [
//       'assets/cmdline.pdf',
//       'assets/cmsc389z.pdf',
//       'assets/tools.pdf',
//     ];
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Terptales"),
//       ),
//       body: ListView.builder(
//         itemCount: bookUrls.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(bookUrls[index]), // Display the actual book title
//             leading: const Icon(Icons.book),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PdfViewer(path: bookUrls[index]),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


