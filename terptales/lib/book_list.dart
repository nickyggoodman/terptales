import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as path;
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:terptales/settings_page.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

// ADDED BY SHAY. A class to represent bookmark
class Bookmark {
  final String pdfPath;
  final int pageNum;

  Bookmark({required this.pdfPath, required this.pageNum});
}

// going off of the example from https://pub.dev/packages/flutter_pdfview/example
class _BookListState extends State<BookList> {
  
  List<String> bookUrls = [];
  List<Uint8List> thumbnails = [];
  List<Bookmark> bookmarks = []; // ADDED BY SHAY
  

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

  // ADDED BY SHAY

  void addBookmark(String path, int num){
    setState(() {
      bookmarks.add(Bookmark(pdfPath: path, pageNum: num));
    });
  }

  void removeBookmark(String path, int num){
    setState(() {
      bookmarks.removeWhere((bookmark) => bookmark.pdfPath == path && bookmark.pageNum == num);
    });
  }

  bool isBookmarked(String path, int num){
    return bookmarks.any((bookmark) => bookmark.pdfPath == path && bookmark.pageNum == num);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terptales',
      debugShowCheckedModeBanner: false,
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
                  //builder: (context) => PDFScreen(path: bookUrls[index]),
                  // ADDED BY SHAY
                  builder: (context) => PDFScreen(path: bookUrls[index], addBookmark: addBookmark, pdfBookmarks: bookmarks, removeBookmark: removeBookmark, isBookmarked: isBookmarked,),
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
  final Function(String, int) addBookmark; // ADDED BY SHAY
  List<Bookmark>pdfBookmarks = [];
  // UPDATED FOR SECOND PART BY SHAY
  final Function(String, int) removeBookmark;
  final Function(String, int) isBookmarked;

  //PDFScreen({Key? key, this.path}) : super(key: key);
  PDFScreen({Key? key, this.path, required this.addBookmark, required this.pdfBookmarks, required this.removeBookmark, required this.isBookmarked}) : super(key: key);  // ADDED BY SHAY

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  // ADDED BY SHAY
  @override
  void initState(){
    super.initState();
    // Check if there is a bookmark for the current pdf path
    final bookmark = widget.pdfBookmarks.lastWhere(
      (bookmark) => bookmark.pdfPath == widget.path,
      orElse: () => Bookmark(pdfPath: '', pageNum: 0), // ADDED BY SHAY
    );
    
    // If there is a bookmark go to it
    if (bookmark.pdfPath != '') {
      setState(() {
        currentPage = bookmark.pageNum;
      });
    }

  }

  @override
  Widget build(BuildContext context){
    // Define the bookmark icon based on the bookmark status ADDED BY SHAY
    late IconData bookmarkIcon;
    if (widget.isBookmarked(widget.path!, currentPage!)) {
      bookmarkIcon = Icons.bookmark;
    } else {
      bookmarkIcon = Icons.bookmark_border;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(widget.path ?? 'No File Selected')),
        // ADDED BY SHAY
        actions: [IconButton(onPressed: () {
          // Remove the bookmark if it is already in the map
          if(widget.isBookmarked(widget.path!, currentPage!)){
            widget.removeBookmark(widget.path!, currentPage!);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark Removed')),);
          }
          else{
            // Add the bookmark
            widget.addBookmark(widget.path!, currentPage!);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark Added')),);
          }
          setState(() {
            // Rebuild the widget
          });
          //widget.addBookmark(widget.path!, currentPage!);
        //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark Added')),);
        },
        // Change the bookmarked icon
        //Icons.bookmark
        icon: Icon(bookmarkIcon),),],
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
