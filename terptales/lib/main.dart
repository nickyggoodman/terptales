import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:pdf_render/pdf_render.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// going off of the example from https://pub.dev/packages/flutter_pdfview/example
class _MyAppState extends State<MyApp> {
  
  List<String> bookUrls = [];
  List<Uint8List> thumbnails = [];
  

  @override
  void initState() {
    super.initState();
    loadPdfAssets();
  }

  // // do what espresso3389 spells.
  // Future<Uint8List?> generatePdfThumbnail(String pdfAssetPath) async {
  //   try {
  //     // Open the PDF document from the asset
  //     final PdfDocument doc = await PdfDocument.openAsset(pdfAssetPath);

  //     // Get the number of pages in the PDF file
  //     final int pageCount = doc.pageCount;

  //     // The first page is 1
  //     final PdfPage page = await doc.getPage(1);

  //     // Render the page as an image
  //     final PdfPageImage pageImage = await page.render();

  //     // Generate dart:ui.Image cache for later use by imageIfAvailable
  //     await pageImage.createImageIfNotAvailable();

  //     // PDFDocument must be disposed as soon as possible
  //     doc.dispose();

  //     // Return the raw RGBA data of the rendered page image
  //     return pageImage.pixels;
  //   } catch (e) {
  //     print('Error generating PDF thumbnail: $e');
  //     return null;
  //   }
  // }


  Future<void> loadPdfAssets() async {
    try {
      // Get list of all assets
      final assetBundle = DefaultAssetBundle.of(context);
      final assetList = await assetBundle.load('AssetManifest.json');
      final manifestMap = json.decode(utf8.decode(assetList.buffer.asUint8List()));
      final assets = manifestMap.keys.where((String key) => key.contains('.pdf'));

      // Iterate through each PDF asset and add its path to bookUrls
      for (var asset in assets) {
        final pdfFile = await fromAsset(asset);
        setState(() {
          bookUrls.add(pdfFile.path);
        });
      }
    } catch (e) {
      print('Error loading PDF assets: $e');
    }
  }

  Future<File> fromAsset(String asset) async {
    try {
      final data = await rootBundle.load(asset);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${path.basename(asset)}'); // Use path.basename
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      throw Exception('Error parsing asset file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terptales',
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(title: const Text ('Terptales')),
        body: ListView.builder(
        itemCount: bookUrls.length, //THIS IS HARD CODED - FIX LATER
        itemBuilder: (context, index) {
          print(bookUrls[index]);
          return ListTile(
            title: Text(path.basename(bookUrls[index])), // THIS IS HARD CODED - FIX LATER
            leading: const Icon(Icons.book),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // FIX - LOOP THROUGH EVERY PATH, NOT JUST cmdlinepath.
                  builder: (context) => PDFScreen(path: bookUrls[index]),
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
        title: Text(path.basename(widget.path ?? 'No File Selected')),
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



 